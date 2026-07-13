{ pkgs, runtime }:

pkgs.runCommand "yazelix-runtime-release-contracts" { } ''
  set -eu

  runtime=${runtime}

  test -x "$runtime/bin/yzx"
  test -s "$runtime/settings_default.jsonc"
  test -s "$runtime/runtime_identity.json"
  test -s "$runtime/runtime_tools.json"
  test -s "$runtime/runtime_components.json"
  test -x "$runtime/toolbin/tu"
  test -x "$runtime/toolbin/ccboard"
  if [ "$(uname -s)" = Linux ] && [ "$(uname -m)" = x86_64 ]; then
    musl_gcc="$runtime/toolbin/x86_64-unknown-linux-musl-gcc"
    test -x "$musl_gcc"
    test -x "$runtime/toolbin/x86_64-unknown-linux-musl-ar"
    test -x "$runtime/toolbin/x86_64-unknown-linux-musl-ranlib"
    printf 'fn main() {}\n' \
      | "$runtime/toolbin/rustc" - --target x86_64-unknown-linux-musl \
        -C "linker=$musl_gcc" -o musl-static-probe
    test -x musl-static-probe
  fi
  test -x "$runtime/runtime_tools/ccboard/bin/ccboard"
  grep -F '"ccboard":' "$runtime/runtime_tools.json" >/dev/null
  grep -F '"commands":["ccboard"]' "$runtime/runtime_tools.json" >/dev/null
  grep -F 'Mission Control launches this tool through libexec/ccboard.' "$runtime/runtime_tools.json" >/dev/null
  test -s "$runtime/runtime_tools/ccboard/runtime-tool-metadata.json"
  grep -F '"source_repo":"https://github.com/FlexNetOS/ccboard"' "$runtime/runtime_tools/ccboard/runtime-tool-metadata.json" >/dev/null
  grep -F '"commands":["ccboard"]' "$runtime/runtime_tools/ccboard/runtime-tool-metadata.json" >/dev/null
  test -s "$runtime/config_metadata/ccboard_runtime_tool.toml"
  grep -F 'YAZELIX_CCBOARD_BIN = "runtime_tools/ccboard/bin/ccboard"' "$runtime/config_metadata/ccboard_runtime_tool.toml" >/dev/null
  grep -F '"codedb":' "$runtime/runtime_tools.json" >/dev/null
  grep -F '"commands":["codedb","nu_plugin_codedb"]' "$runtime/runtime_tools.json" >/dev/null
  test -x "$runtime/runtime_tools/codedb/bin/codedb"
  test -x "$runtime/runtime_tools/codedb/bin/nu_plugin_codedb"
  test -s "$runtime/runtime_tools/codedb/runtime-tool-metadata.json"
  test -s "$runtime/config_metadata/codedb_runtime_tool.toml"
  agent_layout="$runtime/configs/zellij/layouts/flexnetos_agent_workspace.kdl"
  test -s "$agent_layout"
  grep -F 'tab name="Mission Control"' "$agent_layout" >/dev/null
  grep -F 'pane name="ccboard"' "$agent_layout" >/dev/null
  grep -F 'command "__YAZELIX_RUNTIME_DIR__/libexec/ccboard"' "$agent_layout" >/dev/null
  test -x "$runtime/libexec/yazelix_zellij_bar_widget"
  resolved_bar_widget="$(readlink -f "$runtime/libexec/yazelix_zellij_bar_widget")"
  test -x "$resolved_bar_widget"
  grep -F '/toolbin:/nix/store/' "$resolved_bar_widget" >/dev/null
  grep -F '/bin:$PATH' "$resolved_bar_widget" >/dev/null

  # The foundation profile enables Weave's governed-web feature and must ship
  # the separate Obscura process it drives. Keep both commands on the profile
  # bin/toolbin trust roots, then prove a real no-network MCP handshake through
  # `weave web tab_list`. Other Yazelix package shapes contain neither command
  # and intentionally skip this foundation-only contract.
  if [ -e "$runtime/libexec/weave" ] || [ -e "$runtime/libexec/obscura" ]; then
    for command_name in weave obscura; do
      test -x "$runtime/libexec/$command_name"
      test -x "$runtime/toolbin/$command_name"
      test -x "$runtime/bin/$command_name"
      test -L "$runtime/toolbin/$command_name"
      test -L "$runtime/bin/$command_name"
    done

    probe_home="$TMPDIR/weave-obscura-profile-home"
    mkdir -p "$probe_home/.nix-profile/bin"
    ln -s "$runtime/bin/obscura" "$probe_home/.nix-profile/bin/obscura"

    HOME="$probe_home" \
      WEAVE_DB="$probe_home/weave.db" \
      "$runtime/bin/weave" web --list >weave-web-list.txt
    grep -F 'web ops available:' weave-web-list.txt >/dev/null
    grep -F 'tab_list' weave-web-list.txt >/dev/null

    unset WEAVE_MUX_DIR WEAVE_OBSCURA_BIN
    HOME="$probe_home" \
      WEAVE_DB="$probe_home/weave.db" \
      WEAVE_OBSCURA_ALLOW_OPS=tab_list \
      WEAVE_OBSCURA_STEALTH=1 \
      timeout 30 "$runtime/bin/weave" web tab_list >weave-obscura-probe.txt
    grep -F 'No tabs open.' weave-obscura-probe.txt >/dev/null
  fi

  for size in 48x48 64x64 128x128 256x256; do
    test -s "$runtime/assets/icons/$size/yazelix.png"
  done

  test -s "$runtime/configs/zellij/plugins/zjstatus.wasm"
  test -s "$runtime/configs/yazi/plugins/smart-tabs.yazi/main.lua"
  if grep -R -I -F 'https://github.com/dj95/zjstatus/releases/latest/download/zjstatus.wasm' \
    "$runtime/configs" "$runtime/shells" >/dev/null; then
    echo "Yazelix runtime must use packaged file-backed zjstatus.wasm, not upstream URL auto-download" >&2
    exit 1
  fi

  runtime_variant="$(cat "$runtime/runtime_variant")"
  case "$runtime_variant" in
    kitty)
      test -d "$runtime/configs/terminal_emulators/kitty"
      test ! -L "$runtime/configs/terminal_emulators/mars"
      ;;
    mars)
      mars_config="$runtime/share/mars/config.toml"
      test -s "$mars_config"
      grep -F 'family = "JetBrains Mono"' "$mars_config" >/dev/null
      grep -F 'font-family = "Symbols Nerd Font Mono"' "$mars_config" >/dev/null
      grep -F '${pkgs.jetbrains-mono}/share/fonts/truetype' "$mars_config" >/dev/null
      grep -F '${pkgs.nerd-fonts.symbols-only}/share/fonts/truetype/NerdFonts/Symbols' "$mars_config" >/dev/null
      test -d '${pkgs.jetbrains-mono}/share/fonts/truetype'
      test -d '${pkgs.nerd-fonts.symbols-only}/share/fonts/truetype/NerdFonts/Symbols'
      ;;
    *)
      echo "unsupported Yazelix runtime variant: $runtime_variant" >&2
      exit 1
      ;;
  esac

  touch "$out"
''
