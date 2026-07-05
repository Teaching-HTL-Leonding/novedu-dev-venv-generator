# vcoding-env — temporary student coding environments on Azure

This project generates disposable, browser-based coding environments for students
on Azure. One command spins up *N* identical Linux VMs, each running
[code-server](https://github.com/coder/code-server) (VS Code in the browser) over
HTTPS, pre-loaded with a full toolchain and the [pi.dev](https://pi.dev) coding
agent wired to an Azure OpenAI model.

Everything is driven by a single idempotent `deploy.sh` that renders per-VM
cloud-init and deploys Bicep. Re-running it is safe — credentials are persisted
locally and reused, so VMs are not churned.

---

## What gets deployed

For each of `COUNT` environments (default 2), in resource group `vcoding-env`:

| Resource | Detail |
|---|---|
| Linux VM | `Standard_B2als_v2` (2 vCPU / 4 GB), Ubuntu 24.04 LTS |
| OS disk | 64 GB **Standard SSD**, used for all data |
| Public IP | with a clean DNS label → `vcenv-vm-N.<region>.cloudapp.azure.com` |
| Auth | SSH user **`student`** + a generated 10-char password (same password logs into code-server) |
| Tag | every per-VM resource tagged `environment=vcenv-0N` so a whole environment can be filtered at once |

Shared once per deployment: a VNet + subnet and a Network Security Group.

### Ports (NSG)

| Port | Purpose |
|---|---|
| 22 | SSH (user + password) |
| 443 | **code-server over HTTPS** (Caddy, auto Let's Encrypt cert) |
| 80 | Let's Encrypt HTTP-01 challenge + redirect to HTTPS |
| 8080 | **students' own dev servers** (plain HTTP — bind your app to `0.0.0.0:8080`) |

### What's installed on every VM

- **code-server** on `127.0.0.1:9000`, fronted by **Caddy** which terminates TLS
  on `:443` with an automatically issued & renewed Let's Encrypt certificate.
- **Node.js LTS** via **nvm**, plus **TypeScript** and **Vite**.
- **[pi.dev](https://pi.dev) coding agent**, configured (via `~/.pi/agent/models.json`)
  to talk to the Azure OpenAI-compatible endpoint. Two models are registered —
  `gpt-5.4-mini` (default) and `gpt-5.5`. Pi extensions
  [`pi-web-access`](https://pi.dev/packages/pi-web-access) and
  [`@hypabolic/pi-hypa`](https://pi.dev/packages/@hypabolic/pi-hypa) are installed.
- **.NET 10 SDK**, **Python 3** (`python`/`pip`/`venv`), **ImageMagick**,
  **git**, **GitHub CLI (`gh`)**, build-essential.
- A ready-to-hack **`~/website`** workshop project: a minimal Vite + TypeScript
  static site (`index.html` / `index.ts` / `style.css`) whose `npm run dev`
  serves on `0.0.0.0:8080`. It ships an `AGENTS.md` and two Pi skills
  (`find-docs`, `frontend-design`) so students can drive it with pi immediately.

---

## Prerequisites

- **Azure CLI** logged in to the target subscription (`az login`).
- A **`.env`** file next to `deploy.sh` containing the Azure OpenAI key:
  ```
  AZURE_OPENAI_KEY=<your-key>
  ```
- Local tools used by `deploy.sh`: `jq`, `envsubst` (gettext), `base64`,
  `openssl`. (`bicep` is fetched by the Azure CLI automatically.)
- Sufficient regional **vCPU quota** for the `Standard Basv2` family
  (`deploy.sh` checks this before deploying and aborts with guidance if short).

---

## Usage

```bash
./deploy.sh              # create/update the default 2 environments
COUNT=10 ./deploy.sh     # scale to 10 environments (designed up to ~45)
./deploy.sh --verify     # deploy, then smoke-test vcenv-vm-1 via run-command
```

Configuration lives at the top of `deploy.sh`:

| Variable | Default | Meaning |
|---|---|---|
| `RG` | `vcoding-env` | resource group |
| `PREFIX` | `vcenv` | name prefix for all resources |
| `COUNT` | `2` | number of environments (overridable via env var) |
| `LOCATION` | `austriaeast` | Azure region |
| `AZURE_ENDPOINT` | `https://oai-rstropek-sweden.openai.azure.com/` | Azure OpenAI endpoint |
| `AZURE_LLM_DEPLOYMENT` | `gpt-5.4-mini` | default model for pi |
| `SECOND_MODEL` | `gpt-5.5` | also registered in pi |

### Output — the student logins

After a successful deploy, `deploy.sh` prints and writes (into the gitignored
`.state/` directory):

- **`.state/logins.txt`** — a hand-out list: per environment its code-server
  **HTTPS URL**, password, dev URL, and SSH command.
- **`.state/logins.csv`** — the same, spreadsheet-friendly.

The same generated password is used for both code-server (browser) and SSH.

---

## How it works

```
deploy.sh                     Orchestrator: config, quota preflight, credentials,
                              renders cloud-init, runs the Bicep deployment, prints logins.
bicep/
  main.bicep                  RG-scope: builds the network once, then loops one VM per
                              environment. Per-VM config (incl. passwords) is passed as a
                              single @secure() object so secrets stay out of deployment logs.
  network.bicep               VNet + subnet + NSG (22, 80, 443, 8080).
  vm.bicep                    One VM via the Azure Verified Module
                              (avm/res/compute/virtual-machine); sets size, 64 GB Standard
                              SSD, Ubuntu 24.04, public IP + DNS label, per-env tags,
                              and passes the cloud-init customData.
cloud-init/
  bootstrap.sh                Per-VM provisioning TEMPLATE. deploy.sh substitutes the
                              ${VC_*} placeholders (password, API key, models, FQDN),
                              base64-encodes it, and delivers it as cloud-init customData.
.state/                       (gitignored) persisted credentials + generated params + logins.
```

### Idempotency & credentials

Generated per-VM usernames/passwords are stored in `.state/credentials.json` and
**reused** on every subsequent run. Because Bicep receives the same `adminPassword`,
re-running `deploy.sh` does not recreate the VMs. (cloud-init provisioning runs
once, at first boot; changing `bootstrap.sh` therefore only affects *newly created*
VMs.)

### Scaling to many environments

`COUNT` is designed to scale to ~45. The `/24` subnet holds them comfortably, and
`deploy.sh` performs a vCPU-quota preflight (45 environments = 90 vCPUs of the
`Standard Basv2` family) — if the regional quota is too low it stops early and
tells you to request an increase.

---

## Security notes

- code-server is served over **HTTPS** with a trusted Let's Encrypt certificate;
  authentication is a per-VM password. Students' own dev servers on **8080 are
  plain HTTP** by design (scratch/demo traffic).
- These are **disposable** environments. The Azure OpenAI key is embedded in each
  VM's cloud-init (readable on the VM) and passwords are stored locally under
  `.state/` — both acceptable for throwaway student boxes, neither committed to git
  (`.gitignore` excludes `.env` and `.state/`).
- To tear everything down: `az group delete -n vcoding-env --yes`.
