---
id: 019f2211-cf01-7342-b1aa-1f8d7821b1a0
slug: tasks/codedb-envctl-yazelix-config-ingest
title: "Load Yazelix config files into envctl tables through CodeDB"
type: task
status: active
priority: high
tags: [codedb, envctl, yazelix, config, live_test]
---

## Overview

Load Yazelix configuration and settings files into CodeDB/envctl table rows in a systematic order, then prove those rows are visible from the app/runtime surface. This is the follow-on integration task after [[tasks/nu-plugin-codedb-build]]: CodeDB owns accurate file/code/blob/table facts, while `envctl` owns export/materialization so the files can be reproduced later with additional tooling.

The task must use the live `/home/flexnetos/Downloads/nu_plugin` CodeDB plugin/CLI where possible, not only static documentation. Any issue found during live loading, app visibility, table shape, envctl export, config coverage, or reproduction readiness must be recorded as a KB task before it is fixed.

## Goals

- Build an ordered Yazelix config/settings inventory, starting with canonical runtime config surfaces and then moving outward to generated templates, schemas, metadata, Nushell scripts, Zellij layouts, Helix/Yazi/Mars config, and packaging/runtime glue.
- Create or reuse envctl-visible CodeDB tables for file identity, content/blob metadata, path ownership, config family, source ordering, export target, validation state, and reproduction hints.
- Run a live load of Yazelix config/settings files through the CodeDB plugin/CLI into those tables.
- Verify the loaded rows are visible from the app/runtime surface that will consume them.
- Resolve surfaced issues with upgrades only; do not downgrade existing plugin, envctl, Yazelix, Nu, or package behavior to make tests pass.
- Leave enough evidence that envctl can later reproduce the loaded files with explicit materialization tooling.

## Acceptance Criteria

- [x] Current CodeDB plugin/CLI/envctl command surfaces are inspected from the live workspace.
- [x] A systematic ordered inventory of Yazelix config/settings files is recorded.
- [x] Envctl-visible table schema or table rows exist for loaded config/settings files.
- [x] A live test loads the first ordered Yazelix config batch into those tables.
- [x] The app/runtime surface can read or display the loaded rows.
- [x] Any issue surfaced during loading or visibility is captured as a KB task before implementation.
- [ ] All identified Yazelix config and settings files are loaded or each exception is documented with a blocking KB task.
- [x] Verification evidence includes commands, row counts, selected sample rows, and reproduction/export readiness notes.

## Initial Load Order

Start with canonical user/runtime config contracts, then expand outward:

1. Canonical Yazelix semantic settings defaults and schemas under `configs/yazelix/`, `config_metadata/`, or their current repo equivalents.
2. Nushell runtime/init/config bridge files used by Yazelix.
3. Zellij layout/config templates and generated runtime contract files.
4. Helix, Yazi, Mars, terminal-emulator, theme, cursor, and package metadata config files.
5. Nix/Home Manager/desktop/runtime glue that determines where config files are materialized.
6. Generated artifacts and validators only after their source-of-truth files are loaded.

## Constraints

- Preserve source files as input; do not overwrite Yazelix config during ingestion.
- Keep real user HOME unchanged unless the task explicitly creates a temp-HOME test.
- Prefer explicit `/home/flexnetos/FlexNetOS/usr/bin` frontdoors for workspace tools when ambient PATH is misleading.
- Use upgrade/fix-forward changes only; do not downgrade behavior or dependencies to make ingestion work.
- Commit KB progress frequently, scoped to this task and any issue tasks created from discovered problems.

## Progress Log

### 2026-07-02

- Created this active task from the live integration objective.
- First execution slice: inspect CodeDB plugin/CLI/envctl surfaces and derive the ordered Yazelix config inventory before mutating implementation files.
- CodeDB live Nu plugin proof:
  - Command surface: `codedb scan`, `codedb fs entries`, `codedb export`, `codedb tables`, `codedb schema`, `codedb doctor`.
  - `codedb scan /home/flexnetos/FlexNetOS/src/yazelix` returned 3,320 `filesystem_entries`, 5,634 `rust_items`, and a degraded `cargo_packages` row because this repo's Rust workspace is under `rust_core/Cargo.toml`.
  - `codedb fs entries --repo /home/flexnetos/FlexNetOS/src/yazelix --limit 3400` showed the first ordered config batch as table rows: `settings_default.jsonc`, `config_metadata/main_config_contract.toml`, `config_metadata/yazelix_settings.schema.json`, `nushell/config/config.nu`, and `configs/zellij/layouts/flexnetos_agent_workspace.kdl`.
- Envctl source-run proof:
  - `/home/flexnetos/FlexNetOS/usr/bin/envctl` is missing, tracked in [[tasks/codedb-envctl-frontdoor-missing]].
  - Source fallback works from `/home/flexnetos/FlexNetOS/src/envctl` with `cargo run -p envctl`.
  - Upgraded envctl catalog to support `catalog --repo-root /home/flexnetos/FlexNetOS/src/yazelix` without a Yazelix-local envctl `manifest/`.
  - Added Yazelix config-family discovery for `settings_default.jsonc`, `config_metadata/`, `configs/`, `nushell/`, `home_manager/`, `packaging/`, `flake.nix`, `flake.lock`, `release_metadata.toml`, and `rust_core/yazelix_zellij_config_pack/`.
  - Added JSONC settings parsing; issue tracked and fixed in [[tasks/codedb-envctl-jsonc-settings-parser]].
  - Filed remaining Nu/KDL structured parser follow-up as [[tasks/codedb-envctl-nu-kdl-config-parsers]].

## Live Evidence

Commands run on 2026-07-02:

- `nu --no-config-file --plugins /home/flexnetos/Downloads/nu_plugin/target/debug/nu_plugin_codedb -c 'codedb fs entries --repo /home/flexnetos/FlexNetOS/src/yazelix --limit 3400 ...'`
- `cargo run -q -p envctl -- --json catalog --repo-root /home/flexnetos/FlexNetOS/src/yazelix import`
- `cargo run -q -p envctl -- --json catalog --repo-root /home/flexnetos/FlexNetOS/src/yazelix render --out /tmp/yazelix-envctl-catalog-render`

Current envctl import result:

- Tables: 10
- Rows: 1,509
- Components: 0, because the Yazelix repo is intentionally scanned without an envctl manifest
- Config files: 58
- Settings rows: 1,230
- Env vars: 44
- Mutating: false

First ordered batch envctl rows:

- `settings_default.jsonc`: `file_kind = yazelix_settings_default`, `format = jsonc`, `owner_component = yazelix`, `parse_status = ok`
- `config_metadata/main_config_contract.toml`: `file_kind = yazelix_config_metadata`, `format = toml`, `owner_component = yazelix`, `parse_status = ok`
- `config_metadata/yazelix_settings.schema.json`: `file_kind = yazelix_config_metadata`, `format = json`, `owner_component = yazelix`, `parse_status = ok`
- `nushell/config/config.nu`: `file_kind = yazelix_nushell_config`, `owner_component = yazelix`, `parse_status = not_parsed`
- `configs/zellij/layouts/flexnetos_agent_workspace.kdl`: `file_kind = yazelix_runtime_config`, `format = kdl`, `owner_component = yazelix`, `parse_status = not_parsed`

App/dashboard visibility:

- `envctl catalog render` produced 30 generated files under `/tmp/yazelix-envctl-catalog-render`.
- The rendered app/dashboard file is `/tmp/yazelix-envctl-catalog-render/dashboard/mission-control.catalog.kdl`.
- That dashboard was generated from source tables `paths+settings` and includes `pane command="envctl" args="catalog" "scan" "--json" // paths=49 settings=1230`.
- The rendered table `/tmp/yazelix-envctl-catalog-render/catalog/tables/config_files.json` contains the loaded Yazelix config rows.

Verification gates passed:

- `cargo fmt --check` in envctl.
- `cargo test -p envctl-engine catalog::tests`.
- `cargo test -p envctl --test cli_contract catalog_repo_root_imports_yazelix_config_without_manifest`.
