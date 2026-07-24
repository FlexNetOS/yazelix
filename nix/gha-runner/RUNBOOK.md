# FlexNetOS runner — operations runbook (register · run · reboot · recover)

Companion to `README.md` (architecture). This is the **operator** doc: the exact commands to
stand the runner up, keep it up across reboots, and hand back the owner-gated steps a session
cannot perform. Every step names its verification (an exit code, not an opinion).

Grounded: metaharness ADR-033 (`metaharness/docs/adrs/ADR-033-host-github-actions.md`);
launcher `scripts/runner.nu`; mint `scripts/mint-runner-token.nu`; boot wrapper
`scripts/runner-boot.nu`; boot closure app `nix run .#service` (NO systemd unit).

---

## 0. Owner fences (a session structurally cannot do these)

| # | Fence | Why | Exact owner action |
|---|---|---|---|
| F1 | **envctl in the profile** | The parent Yazelix flake builds pinned `envctl`, `secretctl`, and USB-capable `secretd` sources into the single `lifeos_foundation_yzx` element; the boot closure resolves `secretctl` only from that profile. | Update the foundation element and verify `envctl --version`, `secretctl --help`, and `secretd --version`; never add a second profile element. |
| F2 | **Vault unlocked** | The GitHub-App private key is sealed **broker-only** and USB-gated; mint fails closed when locked. | Start `secretd`, unlock the vault (USB key present), confirm `secretctl … status` shows unlocked. |
| F3 | **App permission** | Creating a runner registration token needs the App installation to hold `organization_self_hosted_runners: write`. | On the FlexNetOS App (id 4044997, installation 140063898), grant that permission; re-accept the install. |
| F5 | **Live org registration + push** | Registering a real runner and dispatching a workflow are irreversible org-side actions. | Run §2–§3, then push to trigger, then §Verify. |
| F6 | **docker group** (Omada MCP only) | `docker.sock` is `660 root:docker`; the session user is not in `docker`. | `sudo usermod -aG docker "$USER"` + re-login — only needed for the network-control Omada stack, **not** for the runner. |

---

## 1. Preflight (no token, no side effects)

```bash
cd ~/meta/src/yazelix/nix/gha-runner
nix run .#runner -- doctor          # substrate + agent layers resolve; want exit 0
nu scripts/mint-runner-token.nu --dry-run   # prints the mint chain; mints nothing
```

## 2. Register (mint → configure)

```bash
# One line: mint a fresh registration token and register. Token never hits a log or history.
GHA_RUNNER_TOKEN=$(nu scripts/mint-runner-token.nu) nix run .#register
```

Verify: `test -f "$XDG_RUNTIME_DIR/yazelix/profile-runtime/gha-runner/state/.runner"` → exit 0
(the runner is configured), and the runner shows **online** under
`gh api orgs/FlexNetOS/actions/runners` with labels `self-hosted,flexnetos,nix`.

## 3. Run (foreground)

```bash
nix run .#runner -- run             # executes ALL workflows/actions on this host
```

## 4. Reboot persistence (nix-native — NO systemd, NO system depths)

> **HARD RULE: NO_SYSTEM_DEPTHS** (exception: the Nix store). `systemd --user` +
> `loginctl enable-linger` is forbidden — linger writes `/var/lib/systemd/linger/$USER` and arms a
> system-managed user manager at boot. The prior systemd unit was **removed**. The nix-native
> persistence design (session-hook autostart, pidfile-guarded, ruflo `daemon-autostart` pattern) or
> the deliberate "not at all" decision is tracked in **[[tasks/gha-runner-nix-native-persistence]]**.

`profile-runtime` is tmpfs-backed (`/run`), so a reboot wipes `.runner`/`.credentials`; a durable
runner must **re-mint → re-register (`config.sh --replace`) → run**. Until the nix-native design
lands, bring the runner up per session (foreground §3, or the boot closure below), NOT via systemd:

```bash
nix run .#service            # mint → register(--replace) → run, one nix-store closure
```

## 5. Recover (after reboot / crash)

Re-run the boot closure — it re-mints and re-registers idempotently (needs F2: vault unlocked, or
the `gh` org-admin token path):

```bash
nix run .#service
```

If the vault is locked it fails closed (no fallback to a stored token) — that is correct. Durable
auto-start across reboots without systemd is the open design in
[[tasks/gha-runner-nix-native-persistence]].

## 6. CUDA agent inference (verified)

The rUv inference backend builds for this host's **2× RTX 5090 / CUDA 13.3** (compute cap 12.0):

```bash
cd ~/meta/src/meta-ruvector
cargo build -p ruvllm --release --features inference-cuda,fused-act        # exit 0; compiles PTX
cargo run   -p ruvllm --release --example cuda_probe --features inference-cuda,fused-act
#   → "CUDA device 0 opened: Cuda(CudaDevice(DeviceId(1)))" + tensor alloc; exit 0
```

Flags are real (crates/ruvllm/Cargo.toml): `inference-cuda = ["candle","cuda"]` (:196),
`fused-act = ["cuda","dep:cudarc"]` (:187). The draft's `inference-cuda` spelling is correct;
`fused-act` gives the ACT-halting fused kernel (ruv-gists/359d4335). Wiring ruvllm into a
metaharness workflow step is the agent-layer follow-on (runs on the substrate per §Run).

## 7. Legacy runner `flexnetos-01` — retirement plan

`flexnetos-01` is a **repo-level** runner on FlexNetOS/yazelix (vendor tarball under
`meta/var/ci/actions-runner-yazelix`, `nohup ./run.sh`), labels `self-hosted,Linux,X64,local,flexnetos`
(**no `nix` label** → no clash with this runner's `[self-hosted,flexnetos,nix]`). It is repeatedly
failing `linux` jobs. Retire **only after** this runner is live and green (owner sign-off — do not
deregister unilaterally):

1. Confirm this flake runner is online and has executed the target workflows green.
2. Drain: stop dispatching to `local` — move any `runs-on: [...,local]` jobs to
   `[self-hosted,flexnetos,nix]` (README diff, not an in-place CI flip — heal-not-harm).
3. Stop it: `kill` the `run.sh` pid (log `meta/var/log/github-runner-yazelix.log`).
4. Deregister: `./config.sh remove --token $(gh api -X POST repos/FlexNetOS/yazelix/actions/runners/remove-token -q .token)`.
5. Archive the tarball dir under `meta/var/archives/`; remove the nohup autostart.

---

## Architectural note — network-control is NOT the runner/agent MCP persistence

The `~/meta/src/network-control` repo persists the **Omada SDN MCP** (`jmtvms/tplink-omada-mcp`,
network-fabric management) via docker-compose `restart: unless-stopped` — it is unrelated to the
runner and to any agent MCP. Its own gaps (missing `.env` — now templated as
`infrastructure/mcp/.env.example`; nothing performs the initial `docker compose up` at boot;
controller-IP/user/path drift across README/CLAUDE/compose; needs F6) are a **separate** owner
item. The runner's and agent layer's per-session start is delivered here by §4 (the nix-store boot
closure `nix run .#service`, NO systemd), not by network-control; durable no-systemd auto-start is
the open design in `tasks/gha-runner-nix-native-persistence`.
