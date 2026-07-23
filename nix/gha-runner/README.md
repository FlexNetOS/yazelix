# FlexNetOS self-hosted GitHub runner — composed Nix flake, zero OS deps

A self-hosted GitHub runner for the FlexNetOS org, built as a **hermetic Nix flake** with
**zero OS system dependencies** — no systemd, no host services, no `apt`. Two layers, one closure:

| Layer | What | Source |
|---|---|---|
| **Substrate** | nixpkgs `github-runner` (the **real** `actions/runner`), registered to the FlexNetOS org, `runs-on: [self-hosted, flexnetos, nix]` — executes **ALL** workflows/actions, incl. the `archbp-*` env tests | nixpkgs (pinned to yazelix's lock rev) |
| **rUv agent** | `@metaharness/host-github-actions` v0.1.2 + `agentic-flow`, invoked **by workflows as a step on the substrate** | ADR-033; `worldgraph/.github/workflows/worldgraph.yml` |
| **Foundation** | one hermetic flake · yazelix-launched · Nushell scripts · envctl-minted token · profile-runtime state | FlexNetOS constraints |

## Why this exists
GitHub-hosted runners cannot execute the FlexNetOS-environment tests (`archbp-*` — cold-reboot,
os-update, dirty-shutdown, swarm-scale harnesses); they need the nix/yazelix foundation. The
substrate runs them locally so lifeos CI can go legitimately green; the metaharness layer adds
rUv-native agentic CI jobs (triage, genome reports, audits) on the same runner.

## How the layers compose (grounded in rUv source)
`metaharness/docs/adrs/ADR-033-host-github-actions.md`: the metaharness harness is a
**composite action + workflow** that runs *on* a GitHub runner — hosted or self-hosted. rUv's
own `worldgraph.yml` uses `runs-on: ubuntu-latest`; ours points the same shape at
`runs-on: [self-hosted, flexnetos, nix]`. The substrate executes the job; the harness
(plain-ESM `bin/cli.js`, `--gha-mode`, exit 0/1/2) is the step. Not competing designs — layers.

nixpkgs patches `actions/runner` to resolve mutable state (`.runner`, `.credentials`, work dir)
from `RUNNER_ROOT` instead of its install dir, so it runs from the immutable store with all
state under `profile-runtime/gha-runner/` (path law).

## Hard constraints (enforced by `verify.mjs`, 24 gates)
- ZERO OS system deps · path law (profile-runtime only; no home dot-local paths) · `bun`/`bunx` runtime
  (never bare `node`/`npx`) · Nushell scripts · substrate wired (`GHA_SUBSTRATE`, org URL,
  labels, register/run) · rUv-native harness deps · nixpkgs pinned by exact rev.

## Layout
| Path | Role |
|---|---|
| `flake.nix` | hermetic flake: `packages.substrate` (github-runner) + `packages.metaharness`, apps `runner`/`scaffold`/`verify`, devShell |
| `scripts/runner.nu` | Nushell launcher: `doctor` / `register` / `run` / `agent` — closure paths via `GHA_SUBSTRATE`/`GHA_BUN` env |
| `harness/package.json` | scaffold target — deps on kernel + host-github-actions + agentic-flow |
| `verify.mjs` | offline gate (run: `bun run verify.mjs`) |

## Build & run
```nu
# 1. Offline gate (no network):
bun run nix/gha-runner/verify.mjs

# 2. Doctor — proves both layers resolve from the closure (no token needed):
nix run .#runner -- doctor

# 3. Register to the FlexNetOS org (token from envctl or gh, env-only):
$env.GHA_RUNNER_TOKEN = (gh api -X POST orgs/FlexNetOS/actions/runners/registration-token --jq .token)
nix run .#runner -- register

# 4. Start the runner — it now executes ALL workflows targeting the labels:
nix run .#runner -- run
```

## The two boundaries a session cannot cross (owner actions)
1. **`npmDepsHash`** (agent layer only) — after `nix run .#scaffold` generates
   `harness/bin/cli.js` + lockfile, the first `nix build .#metaharness` prints the real hash;
   paste it over `lib.fakeHash`. The substrate has no such step — it builds from the binary cache.
2. **Org registration authority** — minting a registration token requires org-admin scope.
   The launcher reads `GHA_RUNNER_TOKEN` from the environment only — it never stores, logs,
   or hardcodes it.

## Integration
Once the runner is online, a lifeos CI job selects it:
```yaml
jobs:
  check:
    runs-on: [self-hosted, flexnetos, nix]
```
This is the one-line lifeos change to apply when landing (kept out of this foundation PR).
