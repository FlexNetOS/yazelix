# FlexNetOS runner — operations runbook (register · run · reboot · recover)

Companion to `README.md` (architecture). This is the **operator** doc: the exact commands to
stand the runner up, keep it up across reboots, and hand back the owner-gated steps a session
cannot perform. Every step names its verification (an exit code, not an opinion).

Grounded: metaharness ADR-033 (`metaharness/docs/adrs/ADR-033-host-github-actions.md`);
launcher `scripts/runner.nu`; mint `scripts/mint-runner-token.nu`; boot wrapper
`scripts/runner-boot.nu`; unit `scripts/gha-runner.service`.

---

## 0. Owner fences (a session structurally cannot do these)

| # | Fence | Why | Exact owner action |
|---|---|---|---|
| F1 | **envctl in the profile** | `envctl secret …` resolves `secretctl` only from `~/.nix-profile/{bin,toolbin}`; absent → fails closed. | Install the staged binaries (`meta/release/staging/…/bin/{envctl,secretctl,secretd}`, verified `envctl 0.1.0` / `secretd 0.1.0`) into the profile, or `cargo install` from `~/meta/src/envctl`. |
| F2 | **Vault unlocked** | The GitHub-App private key is sealed **broker-only** and USB-gated; mint fails closed when locked. | Start `secretd`, unlock the vault (USB key present), confirm `secretctl … status` shows unlocked. |
| F3 | **App permission** | Creating a runner registration token needs the App installation to hold `organization_self_hosted_runners: write`. | On the FlexNetOS App (id 4044997, installation 140063898), grant that permission; re-accept the install. |
| F4 | **linger** | User units start at boot only with linger enabled. | `loginctl enable-linger "$USER"`. |
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

## 4. Reboot persistence (user-level, NO system depths)

`profile-runtime` is tmpfs-backed (`/run`), so a reboot wipes `.runner`/`.credentials`. The unit
therefore **re-mints → re-registers → runs** each boot; `config.sh --replace` makes that
idempotent. This is a `systemd --user` unit — never a system unit, never `/etc`.

```bash
cp scripts/gha-runner.service ~/.config/systemd/user/gha-runner.service
loginctl enable-linger "$USER"                      # F4
systemctl --user daemon-reload
systemctl --user enable --now gha-runner.service
systemctl --user status gha-runner                  # STATE gate: want active/running
```

## 5. Recover (after reboot / crash)

Nothing to do if the unit is installed — it re-mints and re-registers on boot (needs F2: vault
unlocked at boot). Manual path if the unit is not installed:

```bash
cd ~/meta/src/yazelix/nix/gha-runner
nu scripts/runner-boot.nu           # mint → register(--replace) → run
```

If the vault is locked at boot the unit fails closed and retries per `Restart=on-failure`;
`systemctl --user status gha-runner` shows the wall. That is correct — it must never fall back
to a stored token.

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
item. The runner's and agent layer's reboot durability is delivered here by §4 (systemd --user +
linger), not by network-control.
