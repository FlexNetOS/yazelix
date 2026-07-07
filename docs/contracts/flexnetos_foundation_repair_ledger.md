# FlexNetOS Foundation Repair Ledger

This ledger captures the live Yazelix foundation repair state from 2026-07-07.
It is intentionally about installed-runtime ownership, not raw source-tree
success. Generated runtime under `~/.local/share/yazelix` is proof only; edit
inputs under `~/.config/yazelix` or package inputs under this repository.

## Current Installed State

| Surface | Proof |
| --- | --- |
| Active frontdoor | `/home/flexnetos/.nix-profile/bin/yzx` |
| Nix profile element | `nix profile list --json` shows active `lifeos_foundation_yzx` from `path:/home/flexnetos/FlexNetOS/src/yazelix`. |
| Profile target | `/home/flexnetos/.nix-profile/bin/yzx` resolves to `/nix/store/wlnwxa5rncylgylqfvjy32fwzvblyvvf-lifeos-foundation-yzx/bin/yzx`. |
| Runtime identity | clean-env `yzx status` reports runtime dir `/nix/store/wlnwxa5rncylgylqfvjy32fwzvblyvvf-lifeos-foundation-yzx`; `yzx --version-full` reports `v17.9` and `yazelix_yazi_assets` revision `471073d54d4a6c9fa9e87f26134d6db3f387977e`. |
| Current shell caveat | Existing Codex process still inherited older `/nix/store/v1n4m95v55krbji6mhxc40n5y9fnl4b2-yazelix-flexnetos-foundation` environment entries; clean profile-launched `yzx run` resolves `yzx`, `codex`, and `claude` through `.nix-profile` first. |
| Generated runtime | `yzx status` reports `Status up to date`, `Repair needed no`. |
| Health gate | `/home/flexnetos/.nix-profile/bin/yzx doctor` passes. |
| Desktop entry | `com.yazelix.Yazelix.Mars.desktop` uses `Exec="/home/flexnetos/.nix-profile/bin/yzx" desktop launch`. |
| Agent desktop entry | `com.flexnetos.Yazelix.Agent.desktop` uses `YAZELIX_LAYOUT_OVERRIDE="/home/flexnetos/.nix-profile/configs/zellij/layouts/flexnetos_agent_workspace.kdl"` with profile `yzx`. |
| Claude URL handler | `claude-code-url-handler.desktop` uses `Exec="/home/flexnetos/.nix-profile/bin/claude" --handle-uri %u`. |
| Stale local wrapper | `~/.local/bin` contains only `archive`; no `~/.local/bin/yzx` shadow. |
| Menu visual capture | Bounded `yzx menu` capture wrote only terminal alternate-screen/control sequences, so visual gray-cell acceptance still needs a live fresh desktop/session check. |
| Source target | `.#lifeos_foundation_yzx` exists and builds `/nix/store/16ahwljhhyf00gllip06xrcprd8xzp66-lifeos-foundation-yzx`; `.#yazelix_flexnetos_foundation` is no longer exposed in the current worktree after the profile migration. |
| Beads tracking | `yazelix-xig9o` tracks the LifeOS foundation `yzx` ownership migration. |

## Repair Ledger

| component | desired_owner | current_owner | source_repo_or_package | nix_attr | exported_bin | runtime_probe | yzx_menu_cell | current_state | required_action | proof |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| yzx frontdoor | Nix profile package | Nix profile package | `src/yazelix` | `lifeos_foundation_yzx` | `yzx` | `yzx status` | n/a | Runtime healthy; profile attr migrated | Keep profile path as active frontdoor; do not restore user-local wrapper | `nix profile list --json` shows active `lifeos_foundation_yzx`; `readlink -f /home/flexnetos/.nix-profile/bin/yzx` -> `...wln.../bin/yzx` |
| foundation name | LifeOS-owned `lifeos-foundation-yzx` target | Source and profile use LifeOS package target | `src/yazelix` | `lifeos_foundation_yzx` | n/a | `nix build .#lifeos_foundation_yzx` | n/a | Migrated | Keep the old FlexNetOS foundation attr out unless a future compatibility owner requires it | `packaging/flake_outputs.nix` defines `lifeos_foundation_yzx` with `name = "lifeos-foundation-yzx"` |
| RTK | Upstream RTK 0.43.0 | Upstream RTK release package in foundation | `github:rtk-ai/rtk/v0.43.0` via `packaging/rtk_release.nix` | foundation extra runtime package | `rtk` | `rtk --version` | agent wrapper | Repaired | Do not route foundation through `src/rtk-tokenkill` unless a real FlexNetOS delta is required | `/home/flexnetos/.nix-profile/bin/rtk --version` -> `rtk 0.43.0` |
| rtk-tokenkill fork | None unless delta exists | Separate dirty-history fork, not active foundation owner | `src/rtk-tokenkill` | none | none | `git rev-list upstream_tmp/v0.43.0...HEAD` | n/a | Not in sync; not needed for current foundation | Either archive/remove from foundation scope or rebase/sync only if a required delta is proven | fork comparison showed `3 49` divergence |
| Codex | Yazelix profile package plus RTK wrapper policy | Profile toolbin | foundation package | `lifeos_foundation_yzx` | `codex` | `yazelix_zellij_bar_widget codex ...` | `codex_usage` | Working | Keep `codex` wrapped by `rtk codex` in generated shell/session policy | clean `yzx run` resolves `/home/flexnetos/.nix-profile/bin/codex` before runtime-local tool paths |
| Claude | Yazelix profile package | Profile toolbin | nixpkgs `claude-code` with allow-unfree predicate | `lifeos_foundation_yzx` | `claude` | `yazelix_zellij_bar_widget claude ...` | `claude_usage` | Working | Keep unfree allow predicate scoped to `claude-code` | clean `yzx run` resolves `/home/flexnetos/.nix-profile/bin/claude` before runtime-local tool paths |
| Codex/Claude runtime PATH | Nix profile frontdoors first | Installed profile runtime orders profile bins before runtime toolbin/bin and removes stale Yazelix store PATH entries | `rust_core/yazelix_core/src/runtime_env.rs` | `lifeos_foundation_yzx` | `yzx`, `codex`, `claude` | `yzx run command -v ...` | n/a | Repaired for fresh profile-launched sessions | Keep `.nix-profile/bin` first and treat inherited older Yazelix store paths as stale shadows; already-open sessions still need a fresh launch | focused `runtime_env` cargo tests pass; clean profile `yzx run` resolves all three through `.nix-profile/bin` first |
| Claude URL handler | Nix profile `claude` wrapper | User-local desktop handler | `~/.local/share/applications/claude-code-url-handler.desktop` | n/a | `claude` | `xdg-mime query default x-scheme-handler/claude-cli` | n/a | Repaired local handler | Keep profile `Exec`; if a profile-owned desktop handler appears later, migrate away from user-local copy instead of pinning a store private binary | `Exec="/home/flexnetos/.nix-profile/bin/claude" --handle-uri %u` |
| OpenCode | Undecided full-install package and data owner | Missing from PATH/profile; no usage DB | nixpkgs has `opencode` candidate, not currently included | none | missing | `command -v opencode` | removed from active tray | Disabled to avoid gray/empty cell | Decide whether foundation should package `opencode` and how to own `/home/flexnetos/.local/share/opencode/opencode.db`; re-enable tray only after real probe passes | Pure profile PATH reports `opencode` missing; `~/.config/yazelix/settings.jsonc` tray no longer contains `opencode_go_usage`; generated provider flag is false |
| CPU widget | Yazelix generated bar widget | Profile runtime | `yazelix_zellij_bar_widget` | foundation runtime | libexec widget | returns `cpu <percent>` | `cpu` | Working | Keep enabled in active tray | direct widget probe exited 0 |
| RAM widget | Yazelix generated bar widget | Profile runtime | `yazelix_zellij_bar_widget` | foundation runtime | libexec widget | returns `ram <percent>` | `ram` | Working | Keep enabled in active tray | direct widget probe exited 0 |
| Workspace cell | Yazelix pane orchestrator/status bar | Profile generated Zellij config | `src/yazelix` | foundation runtime | generated config/plugin | layout contains `{pipe_workspace}` | `workspace` | Enabled | Verify visually after relaunch; do not edit generated layouts by hand | active config tray includes `workspace` |
| Yazi assets/plugins | Child asset repo consumed by Yazelix package | Yazelix flake input | `src/yazelix-yazi-assets` | `yazelixYaziAssets` input | generated plugin tree | plugin files in profile runtime | n/a | Repaired | Keep child input pinned to published commit with smart tabs | profile plugins include `smart-tabs.yazi` |
| git-kb | Profile package | Profile toolbin | GitKB release packaging | foundation extra runtime package | `git-kb` | `git-kb --version` | n/a | Working | Keep release package, not local binary shim | `/home/flexnetos/.nix-profile/bin/git-kb --version` -> `git-kb 0.2.12` |
| bun | Needs ownership decision | FlexNetOS usr/bin | `/home/flexnetos/FlexNetOS/usr/bin/bun` | none in foundation | not profile exported | `command -v bun` | n/a | Present outside profile only | Decide whether yzx foundation should export or intentionally delegate to FlexNetOS usr/bin | Pure profile PATH reports missing; workspace PATH resolves to `.../FlexNetOS/usr/bin/bun` |
| bunx | Needs ownership decision | FlexNetOS usr/bin | `/home/flexnetos/FlexNetOS/usr/bin/bunx` | none in foundation | not profile exported | `command -v bunx` | n/a | Present outside profile only | Same as bun | Pure profile PATH reports missing; workspace PATH resolves to `.../FlexNetOS/usr/bin/bunx` |
| kache | Needs ownership decision | FlexNetOS usr/bin | `/home/flexnetos/FlexNetOS/usr/bin/kache` | none in foundation | not profile exported | `command -v kache` | n/a | Present outside profile only | Decide profile vs workspace ownership | Pure profile PATH reports missing; workspace PATH resolves to `.../FlexNetOS/usr/bin/kache` |
| wild linker | Needs ownership decision | FlexNetOS usr/bin | `/home/flexnetos/FlexNetOS/usr/bin/wild` | none in foundation | not profile exported | `command -v wild` | n/a | Present outside profile only | Decide profile vs workspace ownership | Pure profile PATH reports missing; workspace PATH resolves to `.../FlexNetOS/usr/bin/wild` |
| meta | Needs ownership decision | FlexNetOS usr/bin | `/home/flexnetos/FlexNetOS/usr/bin/meta` | none in foundation | not profile exported | `command -v meta` | n/a | Present outside profile only | Decide whether foundation owns Meta CLI or delegates to workspace root | Pure profile PATH reports missing; workspace PATH resolves to `.../FlexNetOS/usr/bin/meta` |
| vue | Needs install decision | Missing | nixpkgs or npm/bun package candidate | none | missing | `command -v vue` | n/a | Missing | Decide whether full install needs Vue CLI, Vue language server, or project-local tooling only | `command -v vue` missing |
| vite | Needs install decision | Missing | nixpkgs/npm/bun package candidate | none | missing | `command -v vite` | n/a | Missing | Decide profile export vs project-local dev dependency | `command -v vite` missing |
| tauri | Needs install decision | Missing | nixpkgs/Rust crate candidate | none | missing | `command -v tauri` | n/a | Missing | Decide whether foundation should export `tauri-cli` | `command -v tauri` missing |
| wasmEdge | Needs install decision | Missing | WasmEdge package candidate | none | missing | `command -v wasmEdge` and `command -v wasmedge` | n/a | Missing | Decide casing/package and profile export if required by LifeOS/Yazelix workflows | both commands missing |
| built-in Yazelix tools | Yazelix profile runtime | Profile/runtime closure | `src/yazelix` runtime package list | foundation runtime | mostly not top-level exports | `yzx doctor` | n/a | Healthy | Do not widen profile exports without explicit owner decision | doctor reports runtime healthy; optional `mise` and `tombi` host tools unavailable only |

## Validation Already Run

### 2026-07-07 Codex Profile Path Repair

```text
desktop-file-validate /home/flexnetos/.local/share/applications/claude-code-url-handler.desktop /home/flexnetos/.local/share/applications/com.flexnetos.Yazelix.Agent.desktop /home/flexnetos/.local/share/applications/com.yazelix.Yazelix.Mars.desktop
nix develop --accept-flake-config --no-write-lock-file --command cargo run --quiet --manifest-path rust_core/Cargo.toml -p yazelix_maintainer --bin yzx_repo_validator -- validate-installed-runtime-contract
nix develop --accept-flake-config --no-write-lock-file --command cargo run --quiet --manifest-path rust_core/Cargo.toml -p yazelix_maintainer --bin yzx_repo_validator -- validate-flake-interface
nix build --accept-flake-config --no-write-lock-file .#checks.x86_64-linux.lifeos_foundation_yzx_runtime_release_contracts .#checks.x86_64-linux.runtime_release_contracts .#checks.x86_64-linux.kgp_package_contracts --no-link --print-out-paths --log-format raw
nix build --accept-flake-config --no-write-lock-file .#lifeos_foundation_yzx --no-link --print-out-paths --log-format raw
nix build --accept-flake-config --no-write-lock-file .#codex .#claude --no-link --print-out-paths --log-format raw
nix flake check --accept-flake-config --no-write-lock-file --no-build --log-format raw
nix develop --accept-flake-config --no-write-lock-file --command cargo test --manifest-path rust_core/Cargo.toml -p yazelix_core runtime_env -- --nocapture
nix develop --accept-flake-config --no-write-lock-file --command cargo fmt --all --manifest-path rust_core/Cargo.toml --check
YAZELIX_SKIP_STABLE_WRAPPER_REDIRECT=1 /nix/store/znvz5frvs5aw3dmr6gwlshmwn7njdabd-lifeos-foundation-yzx/bin/yzx run sh -c 'command -v yzx; command -v codex; command -v claude'
env -i HOME=/home/flexnetos USER=flexnetos LOGNAME=flexnetos SHELL=/bin/sh TERM=xterm-256color PATH=/home/flexnetos/.nix-profile/bin:/home/flexnetos/.local/state/nix/profile/bin:/nix/var/nix/profiles/default/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /home/flexnetos/.nix-profile/bin/yzx run sh -c 'command -v yzx; command -v codex; command -v claude'
env -i HOME=/home/flexnetos USER=flexnetos LOGNAME=flexnetos SHELL=/bin/sh TERM=xterm-256color PATH=/home/flexnetos/.nix-profile/bin:/home/flexnetos/.local/state/nix/profile/bin:/nix/var/nix/profiles/default/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /home/flexnetos/.nix-profile/bin/yzx status
/home/flexnetos/.nix-profile/bin/yzx doctor
```

The clean profile runtime proof resolves `yzx`, `codex`, and `claude` through
`/home/flexnetos/.nix-profile/bin` before runtime-local tool paths. The
already-open Codex shell still carries stale `v1n4...-yazelix-flexnetos-foundation`
environment entries from its launch-time session; treat those as inherited
session state, not as the active owner for fresh launches.

```text
env -u FLEXNETOS_GIT_KB_PATH -u FLEXNETOS_RTK_PATH -u NIXPKGS_ALLOW_UNFREE nix build --accept-flake-config .#lifeos_foundation_yzx --no-link --print-out-paths --log-format raw
env -u FLEXNETOS_GIT_KB_PATH -u FLEXNETOS_RTK_PATH -u NIXPKGS_ALLOW_UNFREE nix build --accept-flake-config .#checks.x86_64-linux.lifeos_foundation_yzx_runtime_release_contracts --no-link --print-out-paths --log-format raw
nix develop --accept-flake-config ..#ci -c cargo fmt --check
cargo test -p yazelix_core resolves_rtk_for_codex_agent
cargo test -p yazelix_core codex_without_rtk_is_rejected
cargo test -p yazelix_zellij_config_pack wraps_direct_codex_right_sidebar_with_rtk
/home/flexnetos/.nix-profile/bin/yzx update upstream
/home/flexnetos/.nix-profile/bin/yzx doctor --fix
/home/flexnetos/.nix-profile/bin/yzx desktop install
/home/flexnetos/.nix-profile/bin/yzx doctor
```

## New Session Prompt

```text
You are continuing the FlexNetOS/Yazelix foundation repair from
/home/flexnetos/FlexNetOS/src/yazelix.

Read and obey:
- /home/flexnetos/.codex/RTK.md
- /home/flexnetos/.codex/AGENTS.rtk.md
- /home/flexnetos/FlexNetOS/AGENTS.md
- /home/flexnetos/FlexNetOS/src/yazelix/AGENTS.md
- /home/flexnetos/FlexNetOS/src/lifeos/AGENTS.md if touching LifeOS ownership
- /home/flexnetos/FlexNetOS/src/yazelix-yazi-assets/AGENTS.md if touching Yazi assets

Runtime ownership rules:
- Editable input: /home/flexnetos/.config/yazelix/
- Generated proof: /home/flexnetos/.local/share/yazelix/
- Active frontdoor: /home/flexnetos/.nix-profile/bin/yzx
- Do not hand-edit generated runtime under ~/.local/share/yazelix.
- Do not restore ~/.local/bin/yzx or stale user-local desktop launchers as ownership layers.
- Do not run yzx restart.

Start by verifying current state, not by assuming this prompt is still fresh:
1. cd /home/flexnetos/FlexNetOS/src/yazelix
2. nix run --accept-flake-config .#br -- show yazelix-xig9o
3. git status --short --branch
4. /home/flexnetos/.nix-profile/bin/yzx status
5. /home/flexnetos/.nix-profile/bin/yzx doctor
6. readlink -f /home/flexnetos/.nix-profile/bin/yzx
7. nix profile list --json
8. /home/flexnetos/.nix-profile/bin/yzx --version-full
9. env -i HOME=/home/flexnetos USER=flexnetos LOGNAME=flexnetos SHELL=/bin/sh TERM=xterm-256color PATH=/home/flexnetos/.nix-profile/bin:/home/flexnetos/.local/state/nix/profile/bin:/nix/var/nix/profiles/default/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/sh -lc 'command -v yzx && readlink -f $(command -v yzx)'

Known repaired state as of 2026-07-07:
- Source build of .#lifeos_foundation_yzx passes without NIXPKGS_ALLOW_UNFREE
  and returns a lifeos-foundation-yzx store path.
- .#yazelix_flexnetos_foundation is no longer exposed in the current worktree
  after the active profile migrated to lifeos_foundation_yzx.
- Source runtime-release contracts pass through
  lifeos_foundation_yzx_runtime_release_contracts and require smart-tabs.yazi.
- Profile update through /home/flexnetos/.nix-profile/bin/yzx update upstream succeeded.
- nix profile list --json shows active lifeos_foundation_yzx from path:/home/flexnetos/FlexNetOS/src/yazelix.
- yzx --version-full reports v17.9 and yazi assets revision 471073d54d4a6c9fa9e87f26134d6db3f387977e.
- Profile RTK is upstream rtk 0.43.0.
- Profile git-kb is 0.2.12.
- yzx doctor passes after doctor --fix.
- desktop install was rerun after config updates.
- Source now defines .#lifeos_foundation_yzx with derivation/runtime names
  lifeos-foundation-yzx and lifeos-foundation-yzx-runtime.
- Mars desktop Exec uses /home/flexnetos/.nix-profile/bin/yzx desktop launch.
- Agent desktop Exec uses YAZELIX_LAYOUT_OVERRIDE=/home/flexnetos/.nix-profile/configs/zellij/layouts/flexnetos_agent_workspace.kdl and profile yzx.
- ~/.local/bin/yzx is absent.
- Active widget_tray is ["session","editor","shell","term","workspace","claude_usage","codex_usage","cpu","ram"].
- OpenCode usage is intentionally removed from the active tray because opencode is missing and ~/.local/share/opencode/opencode.db is absent.
- Current running Codex shell may still have an old store path ahead of .nix-profile; treat that as inherited session state and verify fresh-shell PATH before changing packages.

Finish the remaining ownership decisions:
1. Verify .#lifeos_foundation_yzx builds and its store path is named
   lifeos-foundation-yzx. Do not re-add the old
   yazelix_flexnetos_foundation attr unless a future compatibility owner
   proves it is still required.
2. Decide whether rtk-tokenkill is needed at all. Current foundation uses
   upstream RTK 0.43.0 directly. If no FlexNetOS delta is proven, keep
   rtk-tokenkill out of the active foundation path.
3. Decide full-install ownership for bun, bunx, kache, wild, meta, vue, vite,
   tauri, wasmEdge/wasmedge, and opencode. Current state:
   - pure profile PATH exports only yzx, codex, claude, rtk, and git-kb from the required list.
   - bun, bunx, kache, wild, meta resolve only when /home/flexnetos/FlexNetOS/usr/bin is on PATH.
   - vue, vite, tauri, wasmEdge/wasmedge, opencode are missing from both the pure profile and workspace PATH probes.
   - Do not add exports just to make a checklist green. Add a profile package
     only when Yazelix or LifeOS should actually own it.
4. If OpenCode is made part of the foundation, package the binary and define
   the data owner for /home/flexnetos/.local/share/opencode/opencode.db before
   re-enabling zellij.widget_tray opencode_go_usage.
5. Keep Yazi assets pinned to the published child commit that includes
   smart-tabs.yazi, and keep runtime contracts checking that plugin.

Before claiming success, run and report exact proof:
- nix build --accept-flake-config .#checks.x86_64-linux.lifeos_foundation_yzx_runtime_release_contracts --no-link --print-out-paths --log-format raw
- nix build --accept-flake-config .#lifeos_foundation_yzx --no-link --print-out-paths --log-format raw
- /home/flexnetos/.nix-profile/bin/yzx update upstream
- /home/flexnetos/.nix-profile/bin/yzx doctor --fix
- /home/flexnetos/.nix-profile/bin/yzx desktop install
- /home/flexnetos/.nix-profile/bin/yzx status
- /home/flexnetos/.nix-profile/bin/yzx doctor
- command probes for every required exported tool
- desktop Exec proof
- no ~/.local/bin/yzx shadow
- generated runtime proof only, no manual edits under ~/.local/share/yazelix
- live visual proof for any remaining gray/unchecked menu cells; a bounded
  noninteractive yzx menu capture only produced terminal control sequences and
  is not sufficient as acceptance proof.

Do not mark the task done if any gray cell/tool ownership is only hidden by a
workaround. Surface it in the repair ledger with current_state, required_action,
and proof.
```
