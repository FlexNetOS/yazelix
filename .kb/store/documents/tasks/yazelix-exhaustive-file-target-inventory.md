---
id: 019f2289-7a96-7533-8b4d-830dd7f36ddd
slug: tasks/yazelix-exhaustive-file-target-inventory
title: "Inventory every Yazelix file target across repo Nix system and .local depths"
type: task
status: active
priority: high
tags: [codedb, envctl, yazelix, inventory, nix, system, local]
---

# Overview

The first envctl catalog pass intentionally loaded repo-owned Yazelix config/settings surfaces only. That is not broad enough for the next CodeDB target: envctl needs an exhaustive, reproducible inventory of every file related to Yazelix across source checkout, Nix outputs, generated runtime targets, system/user service targets, XDG paths, and `.local` depths.

This task defines the discovery work required before importing file contents into envctl tables. It should produce a concrete target inventory with path ownership, source-of-truth classification, mutation policy, and reproduction semantics for each file or file family.

## Goals

- Locate every Yazelix-related file target, not just files under the Yazelix repo root.
- Include repo source files, Nix expressions, flake inputs/locks, packaged Nix store outputs, runtime generated files, systemd/user service targets, XDG config/data/state/cache surfaces, `$META_ROOT/.local/**`, and real-home `.local/**` bridge/adoption paths when relevant.
- Distinguish source-owned files from generated projections, package outputs, runtime state, cache, logs, compatibility bridges, and user-owned files.
- Preserve safety boundaries: do not mutate real home, system paths, Nix store paths, or user-managed configs during inventory.
- Produce a machine-readable inventory that the Nu plugin/envctl import task can consume.

## Acceptance Criteria

- [ ] Inventory command or script walks all relevant Yazelix roots:
  - [ ] `/home/flexnetos/FlexNetOS/src/yazelix`
  - [ ] `/home/flexnetos/FlexNetOS/src/envctl` surfaces that generate or consume Yazelix catalog rows
  - [ ] `$META_ROOT` layout paths from envctl/yazelix runtime contracts
  - [ ] Nix build outputs and package closures needed to identify packaged Yazelix files
  - [ ] XDG config/data/state/cache targets for Yazelix
  - [ ] `$META_ROOT/.local/**` and any real-home `.local/**` bridge/adoption targets
  - [ ] system/user service and desktop-entry targets that start or supervise Yazelix
- [ ] Each inventory row records absolute path, normalized logical path, owner, source-of-truth class, current existence, file kind, parser hint, mutability, reproduction policy, and safety policy.
- [ ] Nix targets are resolved with cheap eval/build-info probes first, avoiding unnecessary large builds.
- [ ] `.local` and real-home targets are classified as owned, bridge, adopted, ignored, cache/state/log, or unsafe-to-import.
- [ ] The inventory identifies files that should be imported as content blobs versus metadata-only rows.
- [ ] The inventory identifies gaps in the current envctl catalog coverage, including repo-only assumptions from [[tasks/codedb-envctl-yazelix-config-ingest]].
- [ ] The inventory output is committed or rendered to an explicit, reviewable artifact path outside mutable runtime state.
- [ ] Verification proves no source, system, Nix store, or real-home path was mutated during discovery.

## Context

- Prior narrower import task: [[tasks/codedb-envctl-yazelix-config-ingest]]
- Nu plugin package task: [[tasks/nu-plugin-codedb-build]]
- Follow-up import task: [[tasks/nu-plugin-envctl-exhaustive-file-content-import]]

The prior live proof showed envctl could import 58 repo-owned Yazelix config files into 10 catalog tables, but it did not cover `/etc`, `/usr`, `$META_ROOT/.local`, real-home `.local`, or generated runtime/deploy targets. This task is the correction point for that missing scope.

## Implementation Notes

- Start with read-only discovery only.
- Prefer repo-local contracts and existing envctl layout/migration code before adding new traversal rules.
- Treat Nix store paths as immutable package evidence, not write targets.
- Treat real-home `.local` as user-owned unless an existing Yazelix/envctl contract proves a bridge or adoption path.
- The output should be suitable for CodeDB blob/file-table semantics: exact bytes where safe, metadata-only where bytes are unsafe or non-reproducible.

## Completion Evidence

Pending.
