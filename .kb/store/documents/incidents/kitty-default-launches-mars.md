---
id: 019f5105-3a93-7261-b6bd-900f0331f544
slug: incidents/kitty-default-launches-mars
title: "Kitty default still launches Mars"
type: incident
status: investigating
priority: high
---

## Symptom

The installed Yazelix runtime reports the `kitty` runtime variant and reads
`/home/flexnetos/.config/yazelix/settings.jsonc`, but the visible/default
desktop launch still opens Mars with Kitty-oriented generated configuration.

## Expected behavior

Kitty is the selected default terminal. The profile-owned desktop launcher,
runtime package variant, generated terminal configuration, and launched
terminal process must all agree on Kitty.

## Actual behavior

Mars remains the effective default terminal despite the runtime reporting the
Kitty variant.

## Investigation scope

- Prove the active profile frontdoor and immutable package runtime root.
- Inspect the user config without editing generated state.
- Trace desktop entry selection and launch argv to the owning source.
- Distinguish the current live session from next-launch behavior.
- Repair the owning config/package/desktop generation path rather than patching
  `/home/flexnetos/.local/share/yazelix` by hand.

## Acceptance criteria

- [ ] `yzx inspect --json` reports a coherent Kitty runtime and config.
- [ ] The visible/default desktop entry launches the profile-owned `yzx`.
- [ ] The resulting terminal process is Kitty, not Mars.
- [ ] No stale Mars or duplicate desktop entry shadows the selected launcher.
- [ ] Source/package tests cover the regression if a product defect is found.
- [ ] A fresh user-launched window confirms the fix before any non-trivial push.

## Initial evidence

- Profile frontdoor: `/home/flexnetos/.nix-profile/bin/yzx`
- Reported runtime: `v17.9`, variant `kitty`
- Reported config: `/home/flexnetos/.config/yazelix/settings.jsonc`
- Reported install owner: default Nix profile
