# FlexNetOS rUv-native GitHub runner — pure Nix flake, zero OS deps

A self-hosted GitHub runner for the FlexNetOS org, built as a **hermetic Nix flake** with
**zero OS system dependencies** — no systemd, no host services, no `apt`, no tsc build. The
runner is a **rUv-native metaharness agent runner**, not a vanilla `actions/runner`.

## Why this exists
GitHub-hosted runners cannot execute the FlexNetOS-environment tests (`archbp-*` — cold-reboot,
os-update, dirty-shutdown, swarm-scale harnesses); they need the nix/yazelix foundation. This
runner runs them on the local foundation so lifeos CI (`bun run check`) can go legitimately green.

## Architecture (grounded in rUv source)
- **Runner engine** — a metaharness harness: `@metaharness/kernel` + `@metaharness/host-github-actions`
  (`metaharness/docs/adrs/ADR-033-host-github-actions.md`; `--gha-mode` = structured stdout, exit 0/1/2).
- **Shipped as plain ESM `bin/cli.js`, no build step** (`ruv-drone/agent-harness/bin/cli.js`;
  `metaharness` v0.4.1, bin `metaharness`/`harness`). `init` boots kernel+host; `doctor` verifies.
- **Orchestration** — `agentic-flow`.
- **RVM hardware isolation** (`@metaharness/host-rvm`, ADR-018) is **deferred**: RVM is an AArch64
  bare-metal microhypervisor and is not used on the x86_64 foundation. The flake targets both
  `x86_64-linux` and `aarch64-linux` so the RVM path is available on ARM64 later.

## Hard constraints (enforced by `verify.mjs`)
- ZERO OS system deps · path law (profile-runtime, never `~/.local`) · `bun`/`bunx` runtime
  (never bare `node`/`npx`) · Nushell scripts · rUv-native harness deps · nixpkgs pinned.

## Layout
| Path | Role |
|---|---|
| `flake.nix` | hermetic flake: `packages.metaharness` (buildNpmPackage), apps `scaffold`/`runner`/`verify`, devShell |
| `harness/package.json` | scaffold target — deps on kernel + host-github-actions + agentic-flow |
| `scripts/runner.nu` | Nushell launcher: profile-runtime work dir, envctl token, `bun run` the harness |
| `verify.mjs` | offline gate (run: `bun run verify.mjs`) |

## Build & run
```nu
# 1. Offline gate (no network):
bun run nix/gha-runner/verify.mjs

# 2. (network, once) generate the harness bin/cli.js + lockfile into harness/:
nix run .#scaffold

# 3. Build hermetically. First build prints the correct npmDepsHash — paste it into
#    flake.nix (replaces lib.fakeHash), then rebuild:
nix build .#metaharness

# 4. Verify the install (no token needed):
nix run .#runner -- doctor
```

## The two boundaries a session cannot cross (owner actions)
1. **`npmDepsHash`** — computed by the first `nix build` (nix prints the real hash on mismatch).
   This is the one deliberate, reviewable build step; it pins the npm closure hermetically.
2. **Live org registration** — the runner registration token is **minted by envctl** (the sole
   secret boundary) and exported as `GHA_RUNNER_TOKEN`; then:
   ```nu
   $env.GHA_RUNNER_TOKEN = (envctl mint gha-runner-token --org FlexNetOS)  # owner action
   nix run .#runner -- init
   ```
   The launcher reads the token from the environment only — it never stores, logs, or hardcodes it.

## Integration
Once the runner is online (labels `self-hosted, flexnetos, nix`), a lifeos CI job selects it:
```yaml
jobs:
  check:
    runs-on: [self-hosted, flexnetos, nix]
```
This is the one-line lifeos change to apply when landing (kept out of this foundation PR).
