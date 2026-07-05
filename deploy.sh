#!/usr/bin/env bash
#
# deploy.sh — idempotent generator for temporary student coding environments in Azure.
#
# Creates $COUNT Linux VMs (Standard_B2als_v2, 64GB Standard SSD) in resource group
# $RG, each provisioned via cloud-init with code-server, nvm+Node LTS, the pi.dev
# coding agent (Azure OpenAI-compatible), .NET 10, git and the GitHub CLI.
#
# Idempotency: generated per-VM credentials are persisted in .state/credentials.json
# and reused on re-runs, so re-deploying does not churn the VMs. Re-run safely.
#
# Usage:
#   ./deploy.sh            # deploy / update
#   ./deploy.sh --verify   # deploy, then smoke-test vcenv-vm-1 via run-command
#   COUNT=10 ./deploy.sh   # override the VM count (spec default is 2, scales to ~45)

set -euo pipefail

# ------------------------------------------------------------------ configuration
RG="vcoding-env"
PREFIX="vcenv"
COUNT="${COUNT:-2}"
LOCATION="austriaeast"
AZURE_ENDPOINT="https://oai-rstropek-sweden.openai.azure.com/"
AZURE_LLM_DEPLOYMENT="gpt-5.4-mini"   # default model pi uses (cheaper)
SECOND_MODEL="gpt-5.5"                # also registered in pi
ADMIN_USERNAME="student"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_DIR="$SCRIPT_DIR/.state"
CRED_FILE="$STATE_DIR/credentials.json"
PARAMS_FILE="$STATE_DIR/params.json"
LOGINS_TXT="$STATE_DIR/logins.txt"
LOGINS_CSV="$STATE_DIR/logins.csv"
BOOTSTRAP_TMPL="$SCRIPT_DIR/cloud-init/bootstrap.sh"

VERIFY=false
[[ "${1:-}" == "--verify" ]] && VERIFY=true

# ------------------------------------------------------------------ preflight
for cmd in az jq envsubst base64 openssl od fold awk; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "ERROR: required command '$cmd' not found" >&2; exit 1; }
done

mkdir -p "$STATE_DIR"; chmod 700 "$STATE_DIR"

# API key for pi.dev comes from .env
if [[ -f "$SCRIPT_DIR/.env" ]]; then set -a; source "$SCRIPT_DIR/.env"; set +a; fi
: "${AZURE_OPENAI_KEY:?ERROR: AZURE_OPENAI_KEY not set (expected in .env)}"

echo ">> Subscription : $(az account show --query name -o tsv)"
echo ">> Location     : $LOCATION"
echo ">> VM count     : $COUNT"

# ------------------------------------------------------------------ vCPU quota preflight
needed=$((COUNT * 2))   # 2 vCPUs per B2als_v2 (quota family: standardBasv2Family)
avail=$(az vm list-usage -l "$LOCATION" -o json \
  | jq -r '[.[] | select(.name.value | test("Basv2"; "i")) | ((.limit|tonumber) - (.currentValue|tonumber))] | first // empty' 2>/dev/null || true)
if [[ -n "${avail:-}" ]]; then
  echo ">> B2als_v2 vCPUs free in $LOCATION: $avail (need $needed)"
  if (( avail < needed )); then
    echo "ERROR: insufficient B-series-v2 vCPU quota in $LOCATION." >&2
    echo "       Request an increase (Portal > Quotas, or 'az quota' / support request) and retry." >&2
    exit 1
  fi
else
  echo ">> WARN: could not read BALSv2 quota; continuing."
fi

# ------------------------------------------------------------------ resource group
az group create -n "$RG" -l "$LOCATION" -o none
echo ">> Resource group '$RG' ready."

# ------------------------------------------------------------------ credentials (persist + reuse)
[[ -f "$CRED_FILE" ]] || echo '{}' > "$CRED_FILE"
chmod 600 "$CRED_FILE"

# pick one random char from $1 using /dev/urandom (good entropy, no $RANDOM subshell issues)
pick() { local s="$1" n idx; n=$(od -An -N2 -tu2 /dev/urandom | tr -d ' '); idx=$((n % ${#s})); printf '%s' "${s:idx:1}"; }

# 10-char password: >=1 upper, lower, digit, special (Azure Linux complexity), then shuffled
gen_password() {
  local special='._-+=' pool='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789' p="" i
  p+=$(pick 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')
  p+=$(pick 'abcdefghijklmnopqrstuvwxyz')
  p+=$(pick '0123456789')
  p+=$(pick "$special")
  for i in 1 2 3 4 5 6; do p+=$(pick "$pool"); done
  printf '%s' "$p" | fold -w1 | awk 'BEGIN{srand()}{print rand()"\t"$0}' | sort | cut -f2 | tr -d '\n'
}

cloud_config_for() {   # $1 = base64 of rendered bootstrap.sh
  printf '#cloud-config\nwrite_files:\n  - path: /opt/vcenv/bootstrap.sh\n    permissions: '\''0755'\''\n    owner: root:root\n    encoding: b64\n    content: %s\nruncmd:\n  - [ bash, /opt/vcenv/bootstrap.sh ]\n' "$1"
}

items_json=()
for i in $(seq 1 "$COUNT"); do
  name="${PREFIX}-vm-${i}"
  pw=$(jq -r --arg n "$name" '.[$n].password // empty' "$CRED_FILE")
  if [[ -z "$pw" ]]; then
    pw=$(gen_password)
    tmp=$(mktemp)
    jq --arg n "$name" --arg u "$ADMIN_USERNAME" --arg p "$pw" \
      '.[$n] = {user:$u, password:$p}' "$CRED_FILE" > "$tmp" && mv "$tmp" "$CRED_FILE"
    echo ">> [$name] generated new credentials"
  else
    echo ">> [$name] reusing stored credentials"
  fi

  # Predictable public FQDN (dns label = VM name, per vm.bicep); Caddy uses it for TLS.
  fqdn="${name}.${LOCATION}.cloudapp.azure.com"
  export VC_STUDENT_USER="$ADMIN_USERNAME" VC_STUDENT_PASSWORD="$pw" \
         VC_AZURE_ENDPOINT="$AZURE_ENDPOINT" VC_AZURE_OPENAI_KEY="$AZURE_OPENAI_KEY" \
         VC_MODEL_DEFAULT="$AZURE_LLM_DEPLOYMENT" VC_MODEL_SECOND="$SECOND_MODEL" \
         VC_FQDN="$fqdn"
  rendered=$(envsubst '${VC_STUDENT_USER} ${VC_STUDENT_PASSWORD} ${VC_AZURE_ENDPOINT} ${VC_AZURE_OPENAI_KEY} ${VC_MODEL_DEFAULT} ${VC_MODEL_SECOND} ${VC_FQDN}' < "$BOOTSTRAP_TMPL")
  b64=$(printf '%s' "$rendered" | base64 | tr -d '\n')
  cc=$(cloud_config_for "$b64")

  items_json+=("$(jq -n --arg name "$name" --arg u "$ADMIN_USERNAME" --arg p "$pw" --arg cd "$cc" \
    '{name:$name, adminUsername:$u, adminPassword:$p, customData:$cd}')")
done
chmod 600 "$CRED_FILE"

# ------------------------------------------------------------------ parameters file
items=$(printf '%s\n' "${items_json[@]}" | jq -s '.')
jq -n --arg prefix "$PREFIX" --arg location "$LOCATION" --argjson items "$items" '
  {
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    contentVersion: "1.0.0.0",
    parameters: {
      prefix:   { value: $prefix },
      location: { value: $location },
      vms:      { value: { items: $items } }
    }
  }' > "$PARAMS_FILE"
chmod 600 "$PARAMS_FILE"

# ------------------------------------------------------------------ deploy
echo ">> Deploying $COUNT VM(s) — this takes a few minutes..."
az deployment group create \
  --resource-group "$RG" \
  --name vcenv \
  --template-file "$SCRIPT_DIR/bicep/main.bicep" \
  --parameters "@$PARAMS_FILE" \
  --output none
echo ">> Deployment complete."

# ------------------------------------------------------------------ distributable logins
# The same generated password is used for both Code Server (browser) and SSH.
pips=$(az network public-ip list -g "$RG" -o json)

echo "environment,code_server_url,code_server_password,dev_url,ssh_host,ssh_user,ssh_password" > "$LOGINS_CSV"
: > "$LOGINS_TXT"
{
  printf '===================  STUDENT LOGINS  ===================\n'
  for i in $(seq 1 "$COUNT"); do
    name="${PREFIX}-vm-${i}"
    pw=$(jq -r --arg n "$name" '.[$n].password' "$CRED_FILE")
    ip=$(echo "$pips"   | jq -r --arg n "$name-" '[.[]|select(.name|startswith($n))][0].ipAddress // "?"')
    fqdn=$(echo "$pips" | jq -r --arg n "$name-" '[.[]|select(.name|startswith($n))][0].dnsSettings.fqdn // ""')
    host="${fqdn:-$ip}"
    cs_url="https://$host/"          # code-server, TLS-terminated by Caddy (uses the FQDN cert)
    dev_url="http://$host:8080/"     # student's own dev server (plain HTTP)
    printf '%s,%s,%s,%s,%s,%s,%s\n' "$name" "$cs_url" "$pw" "$dev_url" "$ip" "$ADMIN_USERNAME" "$pw" >> "$LOGINS_CSV"
    printf '\nEnvironment %d  (%s)\n' "$i" "$name"
    printf '  Code Server (HTTPS) : %s\n' "$cs_url"
    printf '  Password            : %s\n' "$pw"
    printf '  Dev server (HTTP)   : %s   (bind your app to 0.0.0.0:8080)\n' "$dev_url"
    printf '  SSH                 : ssh %s@%s   (same password)\n' "$ADMIN_USERNAME" "$ip"
  done
  printf '\n========================================================\n'
} | tee "$LOGINS_TXT"
chmod 600 "$LOGINS_CSV" "$LOGINS_TXT"
echo ">> Distributable logins written to:"
echo "   - $LOGINS_TXT  (hand-out format)"
echo "   - $LOGINS_CSV  (spreadsheet/import format)"

# ------------------------------------------------------------------ optional verify (vm-1)
if $VERIFY; then
  name="${PREFIX}-vm-1"
  echo ">> Verifying $name (waiting for cloud-init to finish; can take several minutes)..."
  az vm run-command invoke -g "$RG" -n "$name" --command-id RunShellScript \
    --scripts \
      'cloud-init status --wait || true' \
      'echo "=== tool versions ==="' \
      "su - $ADMIN_USERNAME -c 'code-server --version | head -1'" \
      "su - $ADMIN_USERNAME -c 'node -v'" \
      "su - $ADMIN_USERNAME -c 'dotnet --version'" \
      "su - $ADMIN_USERNAME -c 'gh --version | head -1'" \
      "su - $ADMIN_USERNAME -c 'pi --version'" \
      "echo -n 'code-server service: '; systemctl is-active code-server@$ADMIN_USERNAME" \
    --query "value[0].message" -o tsv
fi
