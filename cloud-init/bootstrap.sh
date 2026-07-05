#!/usr/bin/env bash
# vcenv per-VM provisioning script.
# This is a TEMPLATE: deploy.sh renders the ${VC_*} placeholders with envsubst
# (restricted to the VC_* names), base64-encodes the result, and delivers it via
# cloud-init. Every other $shell reference is evaluated at runtime on the VM.
#
# No `set -x` on purpose: it would leak the password / API key into the boot log.
set -euo pipefail
exec > >(tee -a /var/log/vcenv-bootstrap.log) 2>&1
echo "=== vcenv bootstrap starting $(date -u) ==="

# --- Injected by deploy.sh (envsubst) ---
student_user='${VC_STUDENT_USER}'
student_password='${VC_STUDENT_PASSWORD}'
azure_endpoint='${VC_AZURE_ENDPOINT}'
azure_openai_key='${VC_AZURE_OPENAI_KEY}'
model_default='${VC_MODEL_DEFAULT}'
model_second='${VC_MODEL_SECOND}'
code_server_fqdn='${VC_FQDN}'   # public DNS name; Caddy gets a Let's Encrypt cert for it
# -----------------------------------------

export DEBIAN_FRONTEND=noninteractive
# cloud-init's runcmd shell has no HOME; several installers (code-server) need it.
export HOME="${HOME:-/root}"
home_dir="/home/$student_user"

# Defensive: Azure normally creates the admin user before cloud-init runcmd.
id "$student_user" >/dev/null 2>&1 || useradd -m -s /bin/bash "$student_user"

echo "--- installing base packages ---"
apt-get update -y
apt-get install -y curl git unzip jq ca-certificates build-essential apt-transport-https gnupg \
  python3-pip python3-venv python-is-python3 imagemagick

echo "--- installing GitHub CLI ---"
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  -o /etc/apt/keyrings/githubcli-archive-keyring.gpg
chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
arch="$(dpkg --print-architecture)"
echo "deb [arch=$arch signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
  > /etc/apt/sources.list.d/github-cli.list
apt-get update -y
apt-get install -y gh

echo "--- installing .NET 10 SDK ---"
curl -fsSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh
chmod +x /tmp/dotnet-install.sh
/tmp/dotnet-install.sh --channel 10.0 --install-dir /usr/share/dotnet
ln -sf /usr/share/dotnet/dotnet /usr/local/bin/dotnet
cat > /etc/profile.d/dotnet.sh <<'DOTNETEOF'
export DOTNET_ROOT=/usr/share/dotnet
export PATH="$PATH:/usr/share/dotnet"
export DOTNET_CLI_TELEMETRY_OPTOUT=1
DOTNETEOF

echo "--- installing code-server ---"
curl -fsSL https://code-server.dev/install.sh | sh

# code-server listens on localhost only; Caddy terminates TLS and proxies to it.
mkdir -p "$home_dir/.config/code-server"
cat > "$home_dir/.config/code-server/config.yaml" <<EOF
bind-addr: 127.0.0.1:9000
auth: password
password: "$student_password"
cert: false
EOF
chown -R "$student_user:$student_user" "$home_dir/.config"

systemctl daemon-reload
systemctl enable --now "code-server@$student_user"

echo "--- installing Caddy (HTTPS reverse proxy for code-server) ---"
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' \
  | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' \
  > /etc/apt/sources.list.d/caddy-stable.list
apt-get update -y
apt-get install -y caddy

# Caddy obtains & auto-renews a Let's Encrypt cert for the VM's public FQDN,
# serves HTTPS on :443, redirects :80 -> :443, and reverse-proxies to code-server.
# Student dev work stays untouched on plain HTTP :8080.
cat > /etc/caddy/Caddyfile <<EOF
$code_server_fqdn {
    reverse_proxy 127.0.0.1:9000
}
EOF
systemctl enable caddy
systemctl restart caddy

echo "--- installing nvm + Node LTS + pi.dev (as $student_user) ---"
sudo -u "$student_user" -H bash <<'USEREOF'
set -euo pipefail
export NVM_DIR="$HOME/.nvm"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
. "$NVM_DIR/nvm.sh"
nvm install --lts
nvm alias default 'lts/*'
npm install -g @earendil-works/pi-coding-agent
USEREOF

echo "--- configuring pi.dev provider (models.json) ---"
pi_agent_dir="$home_dir/.pi/agent"
mkdir -p "$pi_agent_dir"

# Declarative custom provider + models (pi.dev/docs/latest/models).
# apiKey is resolved at runtime from the AZURE_OPENAI_KEY env var (set below).
cat > "$pi_agent_dir/models.json" <<EOF
{
  "providers": {
    "foundry": {
      "name": "Azure Foundry",
      "baseUrl": "${azure_endpoint%/}/openai/v1",
      "apiKey": "\$AZURE_OPENAI_KEY",
      "api": "openai-completions",
      "models": [
        { "id": "$model_default", "name": "$model_default", "reasoning": true, "input": ["text","image"],
          "cost": {"input":0,"output":0,"cacheRead":0,"cacheWrite":0}, "contextWindow": 272000, "maxTokens": 32768 },
        { "id": "$model_second", "name": "$model_second", "reasoning": true, "input": ["text","image"],
          "cost": {"input":0,"output":0,"cacheRead":0,"cacheWrite":0}, "contextWindow": 272000, "maxTokens": 32768 }
      ]
    }
  }
}
EOF

cat > "$pi_agent_dir/settings.json" <<EOF
{
  "defaultProvider": "foundry",
  "defaultModel": "$model_default"
}
EOF

# Make AZURE_OPENAI_KEY, dotnet and node/pi available to ALL shells (incl.
# non-interactive) by prepending to .bashrc *before* Ubuntu's interactivity guard.
node_bin="$(ls -d "$home_dir/.nvm/versions/node/"*/bin 2>/dev/null | tail -1)"
tmp_bashrc="$(mktemp)"
cat > "$tmp_bashrc" <<EOF
# ---- vcenv environment (loads for all shells, before the non-interactive guard) ----
export AZURE_OPENAI_KEY='$azure_openai_key'
export AZURE_ENDPOINT='$azure_endpoint'
export DOTNET_ROOT=/usr/share/dotnet
export PATH="${node_bin:+$node_bin:}/usr/share/dotnet:\$PATH"
export NVM_DIR="\$HOME/.nvm"
# ---- end vcenv environment ----

EOF
cat "$home_dir/.bashrc" >> "$tmp_bashrc"
mv "$tmp_bashrc" "$home_dir/.bashrc"

chown -R "$student_user:$student_user" "$home_dir/.pi" "$home_dir/.bashrc"

echo "--- pi extensions + workshop website + skills (as $student_user) ---"
sudo -u "$student_user" -H bash <<'USEREOF'
set -uo pipefail
export NVM_DIR="$HOME/.nvm"
. "$NVM_DIR/nvm.sh" >/dev/null 2>&1
nvm use default >/dev/null 2>&1 || true

# --- machine-wide pi extensions ---
pi install npm:pi-web-access
pi install npm:@hypabolic/pi-hypa

# --- workshop website: minimal Vite + TypeScript static site ---
# Students run `npm run dev` -> Vite serves on 0.0.0.0:8080 (the open dev port).
mkdir -p "$HOME/website"
cd "$HOME/website"
npm init -y >/dev/null 2>&1
npm pkg set type=module >/dev/null 2>&1
npm pkg set scripts.dev="vite" >/dev/null 2>&1
npm pkg set scripts.build="vite build" >/dev/null 2>&1
npm pkg set scripts.preview="vite preview --host 0.0.0.0 --port 8080" >/dev/null 2>&1
npm install -D vite typescript >/tmp/website-npm.log 2>&1

cat > vite.config.ts <<'CFG'
import { defineConfig } from 'vite'

// Dev server listens on the VM's open dev port so it is reachable in the browser.
export default defineConfig({
  server: { host: '0.0.0.0', port: 8080, strictPort: true, allowedHosts: true },
})
CFG

cat > tsconfig.json <<'TSC'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "strict": true,
    "skipLibCheck": true
  },
  "include": ["*.ts"]
}
TSC

cat > index.html <<'HTML'
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link rel="stylesheet" href="/style.css" />
    <title>Workshop Website</title>
  </head>
  <body>
    <main>
      <h1>Hello, workshop!</h1>
      <p id="msg"></p>
    </main>
    <script type="module" src="/index.ts"></script>
  </body>
</html>
HTML

cat > index.ts <<'TS'
const msg = document.getElementById('msg')
if (msg) {
  msg.textContent = 'Edit index.html, index.ts and style.css to build your site.'
}
TS

cat > style.css <<'CSS'
:root { color-scheme: light dark; }
body {
  font-family: system-ui, sans-serif;
  margin: 0;
  min-height: 100vh;
  display: grid;
  place-items: center;
}
main { text-align: center; padding: 2rem; }
h1 { font-size: 2rem; margin-bottom: 0.5rem; }
CSS

cat > AGENTS.md <<'MD'
# Workshop environment

You are Pi, a coding agent running inside a temporary student VM (Ubuntu, with
VS Code / code-server open in the browser).

## This project
A minimal Vite static website written in TypeScript.
Files: `index.html` (markup), `index.ts` (logic), `style.css` (styles).

## Running it
- `npm run dev` starts the Vite dev server on 0.0.0.0:8080 (plain HTTP).
- Open the VM's dev URL on port 8080 in a browser to see the site.
- `npm run build` writes a production build to `dist/`.

## Tools available on this machine
Node.js LTS + npm, TypeScript, Vite, .NET 10 SDK, Python 3 (`python`/`pip`/venv),
ImageMagick (image cropping/resizing), git, GitHub CLI (`gh`).

## Skills available to you
- `find-docs` — fetch current library/framework documentation (Context7).
- `frontend-design` — guidance for building polished, modern frontends.

Keep solutions simple and focused on what the student asks.
MD

# --- pi skills (project-scoped -> ./.pi/skills; -a pi -y = only pi, no prompts) ---
npx --yes skills@latest add https://github.com/upstash/context7 --skill find-docs -a pi -y </dev/null
npx --yes skills@latest add https://github.com/anthropics/skills --skill frontend-design -a pi -y </dev/null
USEREOF

# The pi-hypa extension shells out to a `hypa` command; pi's restricted install
# doesn't put it on PATH, so expose the bundled (self-contained) binary here.
hypa_bin="$(ls "$home_dir"/.pi/agent/npm/node_modules/@hypabolic/hypa-*/bin/hypa 2>/dev/null | head -1)"
[ -n "$hypa_bin" ] && ln -sf "$hypa_bin" /usr/local/bin/hypa

echo "=== vcenv bootstrap finished $(date -u) ==="
