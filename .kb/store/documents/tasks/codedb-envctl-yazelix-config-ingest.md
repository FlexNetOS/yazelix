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

- [ ] Current CodeDB plugin/CLI/envctl command surfaces are inspected from the live workspace.
- [ ] A systematic ordered inventory of Yazelix config/settings files is recorded.
- [ ] Envctl-visible table schema or table rows exist for loaded config/settings files.
- [ ] A live test loads the first ordered Yazelix config batch into those tables.
- [ ] The app/runtime surface can read or display the loaded rows.
- [ ] Any issue surfaced during loading or visibility is captured as a KB task before implementation.
- [ ] All identified Yazelix config and settings files are loaded or each exception is documented with a blocking KB task.
- [ ] Verification evidence includes commands, row counts, selected sample rows, and reproduction/export readiness notes.

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
