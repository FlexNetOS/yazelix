---
id: 019f2289-7aaa-7d61-a7a1-01cb2e7d6598
slug: tasks/nu-plugin-envctl-exhaustive-file-content-import
title: "Import exhaustive Yazelix file contents into envctl tables through Nu plugin"
type: task
status: active
priority: high
tags: [codedb, envctl, nu_plugin, nushell, yazelix, blobs, datatables]
---

# Overview

After every Yazelix-related file target is inventoried, CodeDB's Nu plugin should import the safe file contents into envctl-visible tables. The goal is not only path discovery: envctl needs table rows rich enough to reproduce files later, while CodeDB preserves blob/content semantics and native Nushell file-to-table behavior where appropriate.

This task turns the exhaustive Yazelix target inventory into envctl tables, using the Nu plugin as the ingestion engine and envctl as the projection/render/reproduction layer.

## Goals

- Use the Nu plugin from `/home/flexnetos/Downloads/nu_plugin` or its packaged CodeDB runtime location to import Yazelix-related files into envctl tables.
- Preserve exact file bytes for safe import targets with blob hashes and reversible content metadata.
- Use metadata-only rows for unsafe, generated, immutable, cache/log/state, real-home, or non-reproducible targets.
- Leverage Nushell native file-to-table capability for structured formats instead of ad hoc parsing when the plugin can do so safely.
- Make the imported rows visible through envctl table/render/dashboard surfaces.
- Keep envctl responsible for converting table/blob rows back to files when an explicit verifier-gated apply path exists.

## Acceptance Criteria

- [ ] Depends on completed inventory from [[tasks/yazelix-exhaustive-file-target-inventory]].
- [ ] Nu plugin command imports every inventory row into envctl tables or records a precise skipped/metadata-only reason.
- [ ] Table schema includes at minimum:
  - [ ] target id and logical owner
  - [ ] absolute path and normalized path
  - [ ] source-of-truth class
  - [ ] file kind / parser hint
  - [ ] content hash and byte length
  - [ ] blob reference or inline safe structured value
  - [ ] import safety policy
  - [ ] reproduction policy
  - [ ] last observed/provenance fields
- [ ] Structured files are converted to datatable rows where safe: Nix, TOML, JSON/JSONC, KDL, Nu, Lua, YAML, Markdown, service files, desktop entries, shell fragments, and plain config formats.
- [ ] Binary or unsafe files are represented with blob metadata and not lossy text decoding.
- [ ] `.local`, real-home, Nix store, system, generated, cache/state/log, and source files retain distinct safety semantics in envctl.
- [ ] envctl render/import output proves rows are visible from app/dashboard/table surfaces.
- [ ] A no-mutation proof shows the plugin import did not write to source, system, Nix store, real-home, or runtime-owned targets.
- [ ] Round-trip/reproduction planning identifies which rows can be converted back to files now and which require additional verifier-gated tooling.

## Context

- Inventory producer: [[tasks/yazelix-exhaustive-file-target-inventory]]
- Prior repo-only envctl import: [[tasks/codedb-envctl-yazelix-config-ingest]]
- CodeDB Nu plugin package: [[tasks/nu-plugin-codedb-build]]
- CodeDB envctl export contract: [[tasks/nu-plugin-codedb-envctl-export]]

The user expectation is that CodeDB is the more accurate store: it should preserve file/blob semantics and richer Rust/crate/package layers, while envctl can project tables and eventually reproduce files through explicit apply tooling.

## Implementation Notes

- Do not replace CodeDB blob semantics with envctl-only flattened rows.
- Do not silently read real-home or system secrets into content blobs. Use metadata-only rows when safety is uncertain.
- Prefer native Nushell parsing/table conversion for supported file formats.
- Keep all writes to explicit output/catalog/plugin database paths.
- Any discovered import gaps should create additional GitKB tasks before implementation proceeds.

## Progress Notes

### 2026-07-02

- Inventory dependency is implemented by [[tasks/yazelix-exhaustive-file-target-inventory]].
- The import input artifact is `docs/generated/yazelix_file_target_inventory.json`.
- Current artifact summary:
  - 3,549 inventory rows
  - 1,909 `content_blob` candidates
  - 1,640 `metadata_only` rows
  - source-of-truth classes include `repo_source`, `envctl_control_surface`, `nix_store_package_output`, `real_home_runtime_state`, `real_home_user_config`, and `real_home_desktop_entry`
- Next implementation loop should add a Nu plugin or CodeDB CLI command that consumes that artifact and emits envctl-visible rows with hashes/blob references for `content_blob` candidates and precise skip reasons for `metadata_only` rows.

## Completion Evidence

Pending.
