# Project Instructions for AI Agents

This file provides instructions and context for AI coding agents working on this project.

<!-- BEGIN BEADS INTEGRATION v:1 profile:minimal hash:ca08a54f -->
## Beads Issue Tracker

This project uses **br (beads_rust)** for issue tracking. Run `br ready` and `br show <id>` for issue context.

### Quick Reference

```bash
br ready              # Find available work
br show <id>          # View issue details
br update <id> --claim  # Claim work
br close <id>         # Complete work
```

### Rules

- Use `br` for ALL task tracking — do NOT use TodoWrite, TaskCreate, or markdown TODO lists
- Keep `.beads/issues.jsonl` tracked as the durable issue state and `.beads/beads.db` ignored as the local cache
- Do not use the retired tracker workflow

## Session Completion

**When ending a work session**, complete the steps below that apply to the current change. For non-trivial changes, local implementation and validation can be complete before push, but remote push must wait until the user manually tests and approves it. Only trivial changes should follow the immediate push path by default.

**MANDATORY WORKFLOW:**

1. **File issues for remaining work** - Create issues for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **PUSH TO REMOTE** - Required only after the user has manually tested non-trivial changes, or immediately for trivial changes / when the user explicitly asks to push:
   ```bash
   git pull --rebase
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session

**CRITICAL RULES:**
- Do not push non-trivial changes before user manual testing and explicit approval
- Commit finished local work before moving to unrelated work
- If an approved push fails, resolve and retry until it succeeds
<!-- END BEADS INTEGRATION -->


## Build & Test

### Rebuild the installed runtime — one way only

`yazelix_flexnetos_foundation` is installed via `nix profile` against `path:/home/flexnetos/FlexNetOS/src/yazelix`. Rebuild by invoking the standalone script:

```bash
flexnetos-rebuild-yazelix
```

The script lives at `~/.local/bin/flexnetos-rebuild-yazelix` and works in any shell context (interactive, non-interactive, rescue). It handles all the env plumbing internally: `NIXPKGS_ALLOW_UNFREE=1` for `claude-code`, `readlink -f` resolution for the git-kb / rtk / ccboard `FLEXNETOS_*_PATH` env vars (nix rejects `~/.nix-profile/…` symlinks — needs direct store paths), and `nix profile upgrade --impure yazelix_flexnetos_foundation`.

Do NOT copy the raw `nix profile upgrade` command out with hardcoded store hashes for the FLEXNETOS_*_PATH values. Those hashes go stale on every profile upgrade and hardcoding them re-introduces the exact "three-profiles-that-should-be-one" drift class we fixed. There is one way; use it.

Verify the rebuild:

```bash
grep codex_usage_display ~/.nix-profile/settings_default.jsonc  # should mirror src/yazelix/settings_default.jsonc
readlink -f ~/.nix-profile/bin/yzx                              # store hash should differ from prior
```

### Local build toolchain (for `packaging/*_local_binary.nix` inputs)

The FlexNetOS foundation package accepts three locally-built binaries (git-kb, rtk, ccboard) via `FLEXNETOS_*_PATH` env vars. Each binary is a separate Rust build; use this toolchain:

| Tool | Path | Notes |
|---|---|---|
| `cargo` + `rustc` (fenix rust-mixed 1.96) | `/nix/store/b47aazvj6hmsd1i1a6sy9ch5yx8ylvxg-rust-mixed/bin/{cargo,rustc}` | Newer store hashes may exist; `find /nix/store -maxdepth 5 -name 'cargo' -type f \| xargs -I{} sh -c '{} --version'` to check |
| `cargo` nightly (fenix, if needed) | `/nix/store/l831cb33qjq42psp88zdga9zvgn785ix-auditable-cargo-nightly-latest-2026-05-31/bin/cargo` | Cargo-only bundle, no matching rustc — use the rust-mixed above for a full toolchain |
| `kache-rustc-wrapper` | `/home/flexnetos/FlexNetOS/usr/bin/kache-rustc-wrapper` | Replaces sccache. Set as `RUSTC_WRAPPER=`. Compilation cache hits made ccboard rebuild in 2m28s. |
| `wild` linker | `/home/flexnetos/.local/bin/wild` | **CAVEAT**: gcc rejects absolute paths for `-fuse-ld=<path>`. Do NOT set `RUSTFLAGS="-C link-arg=-fuse-ld=/absolute/path/to/wild"` — it errors with `unrecognized command-line option`. Either use `-fuse-ld=wild` (short name, needs `ld.wild` in the gcc search prefix) or drop wild; kache is the primary speed win. |
| `bun` / `bunx` | `/home/flexnetos/.local/bin/{bun,bunx}` | For node commands invoked during build (e.g. codex tooling). |

Recipe used for ccboard v0.24.0 (works, produces `target/release/ccboard`):

```bash
cd <ccboard-source> && \
  PATH="/nix/store/b47aazvj6hmsd1i1a6sy9ch5yx8ylvxg-rust-mixed/bin:$PATH" \
  RUSTC_WRAPPER=/home/flexnetos/FlexNetOS/usr/bin/kache-rustc-wrapper \
  cargo build --release --bin ccboard
```

After the binary lands, install it to the stable staging path (`~/FlexNetOS/usr/bin/<name>`) and the pre-persisted `FLEXNETOS_<NAME>_PATH` env vars will point at it on the next `flexnetos-rebuild-yazelix`.

## Architecture Overview

### Canonical source vs. sibling trees

Three yazelix-named directories exist under `/home/flexnetos/FlexNetOS/src/`. Only one is canonical for this package:

- **`src/yazelix`** — canonical. `nix profile list` shows `yazelix_flexnetos_foundation` locked to `path:/home/flexnetos/FlexNetOS/src/yazelix`. Edits here are the ones that ship after a rebuild.
- **`src/yazelix_new_worktree`** — a stale git worktree of the same repo on branch `worktree/new_worktree`. Not consumed by any build. Safe to ignore.
- **`src/yazelix-helix`** — a separate repo (helix editor fork) consumed via flake input `yazelixHelix`. Not competing with the two above; touch only when explicitly working on the helix bridge.

### Three-profile convergence

The FlexNetOS agent workspace has three artifacts that must reference the same runtime identity:

1. **Custom layout** — `configs/zellij/layouts/flexnetos_agent_workspace.kdl` (a template consumed by `runtime_materialization::resolve_zellij_layout_path`; the runtime detects `__YAZELIX_ZJSTATUS_TAB_TEMPLATE__` and renders it into `~/.local/share/yazelix/configs/zellij/layouts/`). Also shipped into the nix-store profile at `~/.nix-profile/configs/zellij/layouts/flexnetos_agent_workspace.kdl` — identical sha256.
2. **Launch app** — `~/.local/share/applications/com.flexnetos.Yazelix.Agent.desktop` (hand-installed, NOT home-manager managed, safe to edit directly; ownership marker `X-FlexNetOS-Managed=true` keeps `install_ownership_report.rs` from repairing it).
3. **Runtime binary/profile** — `~/.nix-profile/bin/yzx` → `/nix/store/…-yazelix-flexnetos-foundation` (variant `mars`, profile `mars-full`).

## Conventions & Patterns

### Desktop `Exec` lines reference the stable profile, not source

Never point `YAZELIX_LAYOUT_OVERRIDE` (or any other launcher-embedded path) at an absolute path under `/home/flexnetos/FlexNetOS/src/`. Use `~/.nix-profile/configs/zellij/layouts/flexnetos_agent_workspace.kdl` (or another `$HOME/.nix-profile/...` path) instead. The stable-profile symlink follows `nix profile upgrade` automatically; a source-tree absolute path becomes wrong the moment the repo moves or the layout template regenerates.

### The `com.yazelix.Yazelix.Mars.desktop` entry is runtime-owned

It has `NoDisplay=true` and `X-Yazelix-Managed=true`, and `rust_core/yazelix_core/src/install_ownership_report.rs` will repair it if drifted. Do not delete it or edit its `Exec` line — install a sibling FlexNetOS-specific entry (like `com.flexnetos.Yazelix.Agent.desktop`) with `X-FlexNetOS-Managed=true` instead.

### `yzx doctor` warnings after a rebuild — session carryover, not persistent drift

When a shell is spawned by the Yazelix desktop entry, its PATH and several env vars (`EDITOR`, `VISUAL`, `SHELL`, `LG_CONFIG_FILE`, …) are baked with the store hash that was current at launch time. After `nix profile upgrade` swaps the profile to a new store hash MID-SESSION, `yzx doctor` in that same session reports:

- "A stale host-shell yzx function or alias is shadowing the current profile command" — because the old `/nix/store/<old-hash>/bin` still precedes `~/.nix-profile/bin` in that session's PATH. `yzx doctor` sees `type -a yzx` return the old hash first and interprets it as a startup-file shadow.
- "Host <terminal> environment may be contaminated by Mars Terminal launch state" — because `MARS_CONFIG_HOME` (or similar) is a per-launch temp dir path baked into env.

Neither is a startup-file edit. Fix by re-launching the Yazelix desktop entry after a rebuild; the new launch inherits the current profile symlink. To confirm before relaunching, run `type yzx` in a fresh `env -i HOME="$HOME" PATH="$PATH" bash -lc` — it should resolve to `~/.nix-profile/bin/yzx`.

If the warning persists across a fresh login, THEN look at `~/.local/share/yazelix/initializers/{bash,nushell}/*` for hardcoded store paths and search shell rc files for actual `alias yzx=` / `function yzx` definitions.

### `com.flexnetos.Yazelix.Agent.desktop` env-var handoff

Runtime configuration required to rebuild is persisted in `~/.bashrc` and `~/.config/nushell/env.nu`:

- `FLEXNETOS_GIT_KB_PATH="$HOME/.nix-profile/toolbin/git-kb"` (resolves via profile symlink, so the path follows whichever store hash is installed)
- `FLEXNETOS_RTK_PATH="$HOME/.nix-profile/toolbin/rtk"`
- `NIXPKGS_ALLOW_UNFREE` is intentionally scoped to the `flexnetos-rebuild-yazelix` bash function only, not exported globally, to avoid silently pulling unfree packages into unrelated `nix build` calls.

Convenience scripts on PATH (`~/.local/bin/`):

- `flexnetos-rebuild-yazelix` — one-shot rebuild with all required env; self-contained script, works in any shell context
- `flexnetos-doctor` — wraps `command yzx doctor` to bypass any session-level shadowing

### `~/.config/yazelix/zellij.kdl` sidecar — merge trigger caveat

The sidecar is merged into `~/.local/share/yazelix/configs/zellij/config.kdl` at materialization time, but yazelix's freshness hash does NOT include the sidecar file. Editing the sidecar alone will not cause `yzx doctor` to detect drift or re-materialize. To pick up sidecar changes without waiting for the next desktop launch:

```bash
rm -f ~/.local/share/yazelix/state/rebuild_hash
yzx doctor --fix   # detects "needs repair", regenerates config.kdl
```

The sidecar is intended for native zellij keys that yazelix does NOT already render (from `settings.jsonc`) or enforce (from `enforced_top_level_settings` in `rust_core/yazelix_zellij_config_pack/src/lib.rs`). For example: `scrollback_lines_to_serialize` is a good sidecar key; `session_serialization` and `serialize_pane_viewport` are already enforced and don't need duplication.

### Adding a new locally-built binary to the foundation runtime

Follow the same pattern as `git-kb`, `rtk`, and `ccboard`:

1. Create `packaging/<name>_local_binary.nix` copying the `rtk_local_binary.nix` skeleton — pname/mainProgram = binary name, throws if the corresponding `FLEXNETOS_<NAME>_PATH` env var is empty.
2. Edit `packaging/flake_outputs.nix`:
   - Add `flexnetos_foundation_<name> = import ./<name>_local_binary.nix { inherit pkgs; };` in the `let` block.
   - Append `flexnetos_foundation_<name>` to `extraRuntimePackages`.
   - Append the binary name to both `extraRuntimeCommands` and `exportedBinCommands`.
   - Add `<name> = flexnetos_foundation_<name>;` to the `packages` block.
3. Ensure the binary exists at a stable host path before rebuilding (e.g., `~/FlexNetOS/usr/bin/<name>` for user-built tools, or a fixed store path for tools that come from another nix build).
4. Rebuild via the `flexnetos-rebuild-yazelix` bash function — it resolves the FLEXNETOS_*_PATH env vars automatically.

**Symlink gotcha**: `FLEXNETOS_*_PATH` values passed to `nix profile upgrade` must be direct paths, not `~/.nix-profile/…` symlinks. When nix follows a `~/.nix-profile/toolbin/<tool>` symlink and resolves it into the store, the sandbox rejects the resolved path with `install: cannot stat '/nix/store/…'`. `flexnetos-rebuild-yazelix` handles this via `readlink -f`. Rebuild through the script; do not craft ad-hoc `nix profile upgrade` invocations.

## GitKB

This project uses GitKB for knowledge management.

@.kb/AGENTS.md
