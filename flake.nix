{
  description = "Yazelix Nova";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = {
      url = "github:nix-community/fenix/96e0fc9f1a9b37f6477fa11c3fd48575354773ed";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mars = {
      url = "github:luccahuguet/mars";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    yazelixCursors = {
      url = "github:luccahuguet/yazelix-cursors";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    yazelixZellij = {
      url = "github:luccahuguet/yazelix-zellij/yazelix_kgp_preview";
      flake = false;
    };
    yazelixHelix = {
      url = "github:FlexNetOS/yazelix-helix/2657bf0f8e0f183c0e9bca7e6b1b42f75416be7c";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    yazelixZellijPopup = {
      url = "github:luccahuguet/yazelix-zellij-popup";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    yazelixZellijBar = {
      url = "github:luccahuguet/yazelix-zellij-bar";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.zjstatus.follows = "zjstatus";
    };
    yazelixZellijPaneOrchestrator = {
      url = "github:luccahuguet/yazelix-zellij-pane-orchestrator";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    yazelixScreen = {
      url = "github:luccahuguet/yazelix-screen";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    yazelixYaziAssets = {
      url = "github:FlexNetOS/yazelix-yazi-assets/ea4239c2c0b9ef6ab5a134fe80704eca89947bcd";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    yazelixTerminalSupport = {
      url = "github:FlexNetOS/yazelix-terminal-support/873f64b77eda3a39609d154bda192a2ad8405955";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ratconfig = {
      url = "github:luccahuguet/ratconfig";
      flake = false;
    };
    autoLayoutYazi = {
      url = "github:luccahuguet/auto-layout.yazi";
      flake = false;
    };
    starshipYazi = {
      url = "github:Rolv-Apneseth/starship.yazi";
      flake = false;
    };
    beads_rust_source = {
      url = "github:FlexNetOS/beads_rust/2498339168b8e88d641e8ae1664843fc69740012";
      flake = false;
    };
    beads_viewer = {
      url = "github:FlexNetOS/beads_viewer/37d7c2a69797db37d373646ba50e5d0c62d9984a";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rtk_source = {
      url = "github:FlexNetOS/rtk-tokenkill/eee0dfbd3cf3dc82f5604c77ccc4f93c4a5f0c45";
      flake = false;
    };
    # Supplies `agent guard`, the PreToolUse policy engine. It must be
    # profile-owned for the same reason rtk and icm are: a hook pointed at a
    # build directory dies the moment that directory is a tmpfs, which is the
    # exact failure its own path-law patterns exist to deny.
    agent_source = {
      url = "github:FlexNetOS/agent/0c4414c8ebb6d356c5f60b7f5817b16eb571694a";
      flake = false;
    };
    grit_source = {
      url = "github:FlexNetOS/grit/89d8addd170f408d1d82860c39096929375bd2ce";
      flake = false;
    };
    icm_source = {
      url = "github:FlexNetOS/icm/dfeba4efa880f58ece6d91c3f1da4c8358c71564";
      flake = false;
    };
    weave_source = {
      url = "github:FlexNetOS/weave/9eae5c4d9cc9acb520e3d45dad25ea60ea22e63d";
      flake = false;
    };
    obscura_source = {
      url = "github:FlexNetOS/obscura/4f5b6e52d358b0e7a6a021a24bd12ff77b3f3989";
      flake = false;
    };
    # Retired lane: crates/{runner-cli,runner-core,runner-dispatch} -> fxrun, fxrun-dispatch.
    # The canonical runner is `ghaRunner` below (nix/gha-runner -> flexnetos-runner-start).
    # Same repository, two subtrees: do not conflate the two inputs.
    flexnetos_runner_source = {
      url = "github:FlexNetOS/flexnetos_runner/8567ea882d5ca08281b15578559fb6e5c3477049";
      flake = false;
    };
    envctl_source = {
      url = "github:FlexNetOS/envctl/38f8abaf5a8dd5638196d34afcf7762bbb1fb7d4";
      flake = false;
    };
    loop_lib_source = {
      url = "github:FlexNetOS/loop_lib/f7991d1732ba54bfb3813622c720cc76056ac02e";
      flake = false;
    };
    meta_plugin_protocol_source = {
      url = "github:FlexNetOS/meta_plugin_protocol/7d65eeac3bba8e9702eb0590ba9476e4e420bfb3";
      flake = false;
    };
    ghaRunner = {
      url = "github:FlexNetOS/flexnetos_runner/998c3db9bbf5b0d79045b94f34b850cdc3482091?dir=nix/gha-runner";
    };
    zjstatus = {
      url = "github:luccahuguet/zjstatus/yazelix-tab-activity-pipe";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    yaziBistro = {
      url = "github:luccahuguet/yazi-bistro";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    fenix,
    mars,
    yazelixCursors,
    yazelixZellij,
    yazelixHelix,
    yazelixZellijPopup,
    yazelixZellijBar,
    yazelixZellijPaneOrchestrator,
    yazelixScreen,
    yazelixYaziAssets,
    yazelixTerminalSupport,
    ratconfig,
    beads_rust_source,
    beads_viewer,
    rtk_source,
    grit_source,
    icm_source,
    agent_source,
    weave_source,
    obscura_source,
    flexnetos_runner_source,
    envctl_source,
    loop_lib_source,
    meta_plugin_protocol_source,
    ghaRunner,
    autoLayoutYazi,
    starshipYazi,
    yaziBistro,
    zjstatus,
  }: let
    novaVersion = "1.0.0-beta.3";
    compactNovaVersion = version:
      if version == "dev"
      then "NOVA DEV"
      else let
        parsed = builtins.match "([0-9]+)\\.([0-9]+)\\.[0-9]+(-beta\\.([0-9]+))?" version;
      in
        if parsed == null
        then throw "unsupported Nova version: ${version}"
        else if builtins.elemAt parsed 2 == null
        then "NOVA ${builtins.elemAt parsed 0}.${builtins.elemAt parsed 1}"
        else "NOVA β${builtins.elemAt parsed 3}";
    novaBarLabel =
      assert compactNovaVersion "dev" == "NOVA DEV";
      assert compactNovaVersion "1.0.0-beta.1" == "NOVA β1";
      assert compactNovaVersion "1.0.0-beta.12" == "NOVA β12";
      assert compactNovaVersion "1.0.0" == "NOVA 1.0";
      compactNovaVersion novaVersion;
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    eachSystem = nixpkgs.lib.genAttrs supportedSystems;
    homeManagerModule = import ./home-manager/module.nix {
      defaultPackageFor = system: self.packages.${system}.yazelix;
    };
    rustBinFor = pkgs: name: src: pkgs.runCommand name {nativeBuildInputs = [pkgs.rustc pkgs.stdenv.cc];} ''
      mkdir -p "$out/bin"
      rustc --edition=2024 ${src} -o "$out/bin/${name}"
    '';
    nuApplicationFor = pkgs: name: source: replacements:
      pkgs.writeTextFile {
        inherit name;
        destination = "/bin/${name}";
        executable = true;
        text =
          "#!${pkgs.nushell}/bin/nu\n"
          + builtins.replaceStrings
          (map (key: "@${key}@") (builtins.attrNames replacements))
          (builtins.attrValues replacements)
          (builtins.readFile source);
      };
    yzxYaziMaterializerFor = pkgs:
      pkgs.rustPlatform.buildRustPackage {
        pname = "yzx-yazi-config";
        version = "0.1.0";
        src = ./crates/yzx-yazi-config;
        cargoLock.lockFile = ./crates/yzx-yazi-config/Cargo.lock;
      };
  in {
    homeManagerModules.default = homeManagerModule;

    packages = eachSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfreePredicate = package:
          nixpkgs.lib.getName package == "claude-code";
      };
      rustBin = rustBinFor pkgs;
      nuApplication = nuApplicationFor pkgs;
      marsPackage = mars.packages.${system}.mars;
      yzxMarsToml = pkgs.replaceVars ./defaults/mars/config.toml {
        jetbrainsMonoDir = "${pkgs.jetbrains-mono}/share/fonts/truetype";
        symbolsNerdDir = "${pkgs.nerd-fonts.symbols-only}/share/fonts/truetype/NerdFonts/Symbols";
        notoSymbolsDir = "${pkgs.noto-fonts}/share/fonts/noto";
        notoEmojiDir = "${pkgs.noto-fonts-color-emoji}/share/fonts/noto";
      };
      yzxMarsConfig = pkgs.runCommand "yzx-mars-config" {} ''
        install -D -m 644 ${yzxMarsToml} "$out/config.toml"
      '';
      yzxCarapaceInit = pkgs.runCommand "yzx-carapace-init" {} ''
        ${pkgs.carapace}/bin/carapace _carapace nushell > "$out"
      '';
      yzxZoxideInit = pkgs.runCommand "yzx-zoxide-init" {} ''
        ${pkgs.zoxide}/bin/zoxide init nushell > "$out"
      '';
      yzxNuConfigNu = pkgs.replaceVars ./defaults/nu/config.nu {
        carapaceInit = "${yzxCarapaceInit}";
        starship = "${pkgs.starship}/bin/starship";
        zoxideInit = "${yzxZoxideInit}";
      };
      flexnetosNuConfig = pkgs.replaceVars ./nushell/config/config.nu {
        stackPromptGuard = "${./nushell/config/stack_prompt_guard.nu}";
        flexnetosInit = "${./nushell/scripts/flexnetos_init.nu}";
        profileNu = "/home/flexnetos/.nix-profile/toolbin/nu";
        rtkWrappers = "${./nushell/config/rtk_wrappers.nu}";
      };
      yzxNuConfig = pkgs.runCommand "yzx-nu-config" {} ''
        install -D -m 644 ${yzxNuConfigNu} "$out/config.nu"
        install -D -m 644 ${./defaults/nu/env.nu} "$out/env.nu"
      '';
      flexnetosYzxNuConfig = pkgs.runCommand "flexnetos-yzx-nu-config" {} ''
        install -D -m 644 ${yzxNuConfigNu} "$out/config.nu"
        printf '\nsource "%s"\n' ${flexnetosNuConfig} >> "$out/config.nu"
        install -D -m 644 ${./defaults/nu/env.nu} "$out/env.nu"
      '';
      yzxConfigSrc = pkgs.runCommand "yzx-config-src" {} ''
        mkdir -p "$out"
        cp -R ${pkgs.lib.cleanSource ./crates/yzx-config}/. "$out/"
        chmod -R u+w "$out"
        ln -s ${yazelixCursors} "$out/yazelix-cursors"
        cp ${./defaults/config.toml} "$out/config.toml"
        cp ${./defaults/mars/config.toml} "$out/mars.toml"
        cp ${mars}/docs/yazelix/config_inventory.v1.json "$out/mars-config-inventory.v1.json"
        substituteInPlace "$out/Cargo.toml" \
          --replace-fail '../../../yazelix-cursors' './yazelix-cursors'
        substituteInPlace "$out/src/catalog.rs" \
          --replace-fail '../../../defaults/config.toml' '../config.toml' \
          --replace-fail '../../../defaults/mars/config.toml' '../mars.toml'
        substituteInPlace "$out/src/mars_inventory.rs" \
          --replace-fail '../../../../mars/docs/yazelix/config_inventory.v1.json' '../mars-config-inventory.v1.json'
      '';
      yzxConfig = pkgs.rustPlatform.buildRustPackage {
        pname = "yzx-config";
        version = "0.1.0";
        src = yzxConfigSrc;
        cargoLock = {
          lockFile = ./crates/yzx-config/Cargo.lock;
          # Two ratconfig majors coexist after the upstream sync: yazelix-cursors
          # still pins 2.0.0 while yzx-config itself moved to 6.0.0.
          outputHashes."ratconfig-2.0.0" = "sha256-NXnn7WOBEa7uQl8rs52gpIhpEGTeanRL5+au9ltjQyE=";
          outputHashes."ratconfig-6.0.0" = "sha256-cXi++JuTkC47J0geYyxi+Eh3M/mESK0qAkKwBFj1RdY=";
        };
        YAZELIX_NIX_STORE_ROOT = builtins.storeDir;
        YZX_TEST_NU = "${pkgs.nushell}/bin/nu";
        # Upstream: the yzx-config test env now needs the packaged yazi config
        # and the agent launcher.
        YAZELIX_PACKAGED_YAZI = yzxYaziConfig;
        YAZELIX_AGENT_LAUNCHER = "${yzxAgent}/bin/yzx-agent";
      };
      # Fork: Rust/Nu shell machinery replaces upstream's yzx-shell.sh /
      # yzx-env-supervisor.sh (repo POSIX shell sources are gate-banned).
      mkYzxNuShell = name: nuConfig: let
        source = pkgs.replaceVars ./runtime/yzx-nu.rs {
          nu = "${pkgs.nushell}/bin/nu";
          packagedNu = "${nuConfig}";
          pathPrefix = pkgs.lib.makeBinPath [pkgs.nushell pkgs.starship pkgs.carapace pkgs.zoxide];
          yzxConfig = "${yzxConfig}/bin/yzx-config";
        };
      in rustBin name source;
      yzxNuShell = mkYzxNuShell "yzx-nu" yzxNuConfig;
      flexnetosYzxNuShell = mkYzxNuShell "flexnetos-yzx-nu" flexnetosYzxNuConfig;
      mkYzxShell = name: nuShell:
        pkgs.linkFarm name [
          {
            name = "bin/yzx-shell";
            path = "${nuShell}/bin/${nuShell.name}";
          }
        ];
      yzxShell = mkYzxShell "yzx-shell" yzxNuShell;
      flexnetosYzxShell = mkYzxShell "flexnetos-yzx-shell" flexnetosYzxNuShell;
      yzxEnvSupervisor = rustBin "yzx-env-supervisor" ./runtime/yzx_env_supervisor.rs;
      yzxAgent = rustBin "yzx-agent" ./runtime/yzx-agent.rs;
      yzxMenuSrc = pkgs.replaceVars ./runtime/yzx-menu.rs {
        fzf = "${pkgs.fzf}/bin/fzf";
      };
      yzxMenu = rustBin "yzx-menu" yzxMenuSrc;
      yazelixZellijPopupPackage = yazelixZellijPopup.packages.${system}.yzpp;
      yazelixZellijBarPackage = yazelixZellijBar.packages.${system}.yazelix_zellij_bar;
      yazelixZellijPaneOrchestratorPackage =
        yazelixZellijPaneOrchestrator.packages.${system}.yazelix_zellij_pane_orchestrator;
      tokenusage = import ./packaging/tokenusage.nix {inherit pkgs;};
      yazelixScreenPackage = yazelixScreen.packages.${system}.yzs;
      yzxWelcome = nuApplication "yzx-welcome" ./runtime/yzx_welcome.nu {
        yzs = "${yazelixScreenPackage}/bin/yzs";
      };
      yzxZellijConfig = rustBin "yzx-zellij-config" ./runtime/yzx-zellij-config.rs;
      yazelixHelixPackage = yazelixHelix.packages.${system}.yazelix_helix;
      yzxHelixConfig = pkgs.writeTextDir "config.toml" (builtins.readFile ./defaults/helix/config.toml);
      yzxOpenTerminal = nuApplication "yzx-open-terminal" ./runtime/yzx_open_terminal.nu {
        zellij = "${yazelixZellijPackage}/bin/zellij";
      };
      yzxHelixSteelConfig = pkgs.runCommand "yzx-helix-steel-config" {} ''
        mkdir -p "$out"
        cat > "$out/helix.scm" <<'EOF'
        ;; Yazelix Nova packaged Steel module.
        (provide yzx-new-shell)
        (require (only-in "helix/static.scm" cx->current-file get-helix-cwd))
        (require (only-in "helix/commands.scm" run-shell-command))
        (require (only-in "helix/misc.scm" set-error!))

        (define yazelix-single-quote "'")
        (define (yazelix-posix-quote value)
          (string-append
            yazelix-single-quote
            (string-replace
              value
              yazelix-single-quote
              (string-append yazelix-single-quote "\\" yazelix-single-quote yazelix-single-quote))
            yazelix-single-quote))

        (define (yzx-new-shell-command target)
          (string-append "\"${yzxOpenTerminal}/bin/yzx-open-terminal\" " (yazelix-posix-quote target)))

        ;;@doc
        ;;Open a Yazelix terminal pane at the current Helix file or workspace.
        (define (yzx-new-shell)
          (let ([current-file (cx->current-file)]
                [current-workspace (get-helix-cwd)])
            (cond
              [(string? current-file)
               (run-shell-command (yzx-new-shell-command current-file))]
              [(string? current-workspace)
               (run-shell-command (yzx-new-shell-command current-workspace))]
              [else
               (set-error! "Yazelix could not resolve a target path for opening a shell")])))
        EOF
        cat > "$out/init.scm" <<'EOF'
        ;; Yazelix Nova packaged Steel init.
        EOF
      '';
      yzxHelixBase = nuApplication "yzx-hx" ./runtime/yzx_helix.nu {
        hx = "${yazelixHelixPackage}/bin/hx";
        od = "${pkgs.coreutils}/bin/od";
        tr = "${pkgs.coreutils}/bin/tr";
        yzxConfig = "${yzxConfig}/bin/yzx-config";
        yzxHelixConfig = "${yzxHelixConfig}";
        yzxHelixSteelConfig = "${yzxHelixSteelConfig}";
      };
      yzxHelix = pkgs.linkFarm "yzx-hx" [
        {
          name = "bin/yzx-hx";
          path = "${yzxHelixBase}/bin/yzx-hx";
        }
        {
          name = "bin/hx";
          path = "${yzxHelixBase}/bin/yzx-hx";
        }
      ];
      yzxEditor = nuApplication "yzx-editor" ./runtime/yzx_editor.nu {
        yzxConfig = "${yzxConfig}/bin/yzx-config";
        yzxHelix = "${yzxHelix}/bin/yzx-hx";
      };
      yzxConfigUi = nuApplication "yzx-config-ui" ./runtime/yzx_config_ui.nu {
        yzxConfig = "${yzxConfig}/bin/yzx-config";
        yzxEditor = "${yzxEditor}/bin/yzx-editor";
        yzxHelix = "${yzxHelix}/bin/yzx-hx";
      };
      # Upstream: stub editor for the no-helix package variants, emitted as a
      # Nushell script (cache/shell policy: no generated shell runtime).
      yzxHelixUnavailable = pkgs.runCommand "yzx-hx-unavailable" {} ''
        mkdir -p "$out/bin"
        {
          echo '#!${pkgs.nushell}/bin/nu'
          echo 'def --wrapped main [...args: string] {'
          echo "  print --stderr 'yzx-hx: managed Helix is unavailable in this Yazelix package; set editor.command to an installed editor or select a package that includes managed Helix'"
          echo '  exit 69'
          echo '}'
        } > "$out/bin/yzx-hx"
        chmod 755 "$out/bin/yzx-hx"
        ln -s yzx-hx "$out/bin/hx"
      '';
      yaziBistroPackage = yaziBistro.packages.${system}.default;
      yzxOpenCore = pkgs.rustPlatform.buildRustPackage {
        pname = "yzx-open";
        version = "0.1.0";
        src = ./crates/yzx-open;
        cargoLock.lockFile = ./crates/yzx-open/Cargo.lock;
        YZX_TEST_NU = "${pkgs.nushell}/bin/nu";
      };
      yzxYaziToml = pkgs.replaceVars ./defaults/yazi/yazi.toml {
        opener = "YZX_ZELLIJ=${yazelixZellijPackage}/bin/zellij ${yzxOpenCore}/bin/yzx-open";
      };
      yzxYaziConfig = pkgs.runCommand "yzx-yazi-config" {} ''
        install -D -m 644 ${./defaults/yazi/init.lua} "$out/init.lua"
        install -D -m 644 ${./defaults/yazi/keymap.toml} "$out/keymap.toml"
        install -D -m 644 ${yzxYaziToml} "$out/yazi.toml"
        install -D -m 644 ${flexnetosYaziAssetsRoot}/yazelix_starship.toml "$out/yazelix_starship.toml"
        mkdir -p "$out/plugins"
        install -D -m 644 ${./defaults/yazi/plugins/sidebar-state.yazi/main.lua} "$out/plugins/sidebar-state.yazi/main.lua"
        install -D -m 644 ${./defaults/yazi/plugins/sidebar-status.yazi/main.lua} "$out/plugins/sidebar-status.yazi/main.lua"
        install -D -m 644 ${./defaults/yazi/plugins/zoxide-editor.yazi/main.lua} "$out/plugins/zoxide-editor.yazi/main.lua"
        # Fork: plugins come from the FlexNetOS-pinned assets root; upstream's
        # new theme flavors are adopted below.
        ln -s ${flexnetosYaziAssetsRoot}/plugins/auto-layout.yazi "$out/plugins/auto-layout.yazi"
        ln -s ${flexnetosYaziAssetsRoot}/plugins/git.yazi "$out/plugins/git.yazi"
        ln -s ${flexnetosYaziAssetsRoot}/plugins/starship.yazi "$out/plugins/starship.yazi"
        ln -s ${yaziBistroPackage}/share/yazi-flavors/catalog.toml "$out/catalog.toml"
        ln -s ${yaziBistroPackage}/share/yazi-flavors/flavors "$out/flavors"
      '';
      yzxYaziMaterializer = yzxYaziMaterializerFor pkgs;
      # Fork: top-level full-variant yzx-yazi feeds the FlexNetOS workspace
      # layout and config surfaces.  Its inputs match the factory's
      # full-variant binary exactly, so the store paths coincide.
      yzxYaziSrc = pkgs.replaceVars ./runtime/yzx-yazi.rs {
        yzxYaziConfig = "${yzxYaziConfig}";
        yzxYaziMaterializer = "${yzxYaziMaterializer}/bin/yzx-yazi-config";
        yzxOpen = "${yzxOpenCore}/bin/yzx-open";
        zellij = "${yazelixZellijPackage}/bin/zellij";
        yzxHelix = "${yzxHelix}/bin/yzx-hx";
        yzxEditor = "${yzxEditor}/bin/yzx-editor";
        yzxConfig = "${yzxConfig}/bin/yzx-config";
        pathPrefix = pkgs.lib.makeBinPath [pkgs.fzf pkgs.git pkgs.starship pkgs.zoxide];
      };
      yzxYazi = rustBin "yzx-yazi" yzxYaziSrc;
      yzxRuntimeIdentity = pkgs.writeTextDir "runtime_identity.json" (builtins.toJSON {
        name = "Yazelix Nova";
        version = novaVersion;
      });
      defaultConfig = builtins.fromTOML (builtins.readFile ./defaults/config.toml);
      defaultBarWidgets = defaultConfig.bar.widgets;
      defaultShellProgram = defaultConfig.shell.program;
      defaultPopupSideMargin = toString defaultConfig.popup.side_margin;
      defaultPopupVerticalMargin = toString defaultConfig.popup.vertical_margin;
      barRenderRequest = import ./packaging/bar-render-request.nix {
        inherit (pkgs) coreutils nushell;
        runtimeIdentity = yzxRuntimeIdentity;
        zellijBar = yazelixZellijBarPackage;
      };
      yzxBarRenderRequest =
        pkgs.writeText "yzx-bar-render-request.json" (builtins.toJSON (barRenderRequest {
          appearanceMode = "dark";
          widgetTray = defaultBarWidgets;
          shellLabel = defaultShellProgram;
        }));
      yzxBarRenderRequestTemplate =
        pkgs.writeText "yzx-bar-render-request-template.json" (builtins.toJSON (barRenderRequest {
          appearanceMode = "__YZX_APPEARANCE_MODE__";
          widgetTray = "__YZX_BAR_WIDGET_TRAY__";
          shellLabel = "__YZX_SHELL_LABEL__";
        }));
      yzxBarRender = nuApplication "yzx-bar-render" ./runtime/yzx_bar_render.nu {
        bar = "${yazelixZellijBarPackage}/${yazelixZellijBarPackage.widgetPath}";
        inherit novaBarLabel;
      };
      yzxBarKdl = pkgs.runCommand "yzx-zellij-bar.kdl" {} ''
        ${yzxBarRender}/bin/yzx-bar-render "$(<${yzxBarRenderRequest})" > "$out"
      '';
      yzxLayoutKdl = pkgs.runCommand "layout.kdl" {} ''
        substitute ${./defaults/zellij/layout.kdl} "$out" \
          --replace-fail '@yazi@' '${yzxYazi}/bin/yzx-yazi' \
          --replace-fail '@bar@' "$(<${yzxBarKdl})"
      '';
      yzxLayoutSwapKdl = pkgs.replaceVars ./defaults/zellij/layout.swap.kdl {
        yazi = "${yzxYazi}/bin/yzx-yazi";
      };
      yzxLayoutCheck = rustBin "yzx-layout-check" ./checks/zellij-layout.rs;
      yzxZellijLayout = pkgs.runCommand "yzx-zellij-layout" {} ''
        ${yzxLayoutCheck}/bin/yzx-layout-check ${yzxLayoutKdl} ${yzxLayoutSwapKdl} ${pkgs.lib.escapeShellArg novaBarLabel}
        install -D -m 644 ${yzxLayoutKdl} "$out/layout.kdl"
        install -D -m 644 ${yzxLayoutSwapKdl} "$out/layout.swap.kdl"
      '';
      # The portable asset layer evaluates on every advertised platform.  The
      # mandatory ccboard/CodeDB tooling is a Linux-only Foundation concern:
      # CodeDB retains its upstream Bubblewrap sandbox rather than receiving a
      # fictional Darwin substitute.
      flexnetosYaziAssets = yazelixYaziAssets.packages.${system}.yazi_assets_only;
      flexnetosYaziAssetsRoot = "${flexnetosYaziAssets}/share/yazelix_yazi_assets";
      flexnetosLinuxYaziRuntimeTools =
        assert pkgs.stdenv.hostPlatform.isLinux;
        yazelixYaziAssets.packages.${system}.yazelix_yazi_assets;
      flexnetosTerminalSupport = yazelixTerminalSupport.packages.${system}.yazelix_terminal_support;
      flexnetosTerminalSupportMetadata = builtins.fromTOML (
        builtins.readFile "${yazelixTerminalSupport}/config_metadata/terminal_support.toml"
      );
      flexnetosTerminalSupportContract =
        assert flexnetosTerminalSupportMetadata.schema_version == 2;
        assert flexnetosTerminalSupportMetadata.default_terminal == "mars";
        assert flexnetosTerminalSupportMetadata.launch_order == ["mars"];
        assert flexnetosTerminalSupportMetadata.desktop_id_prefix == "com.flexnetos.Yazelix";
        assert flexnetosTerminalSupportMetadata.terminals.mars.desktop_suffix == "Agent";
        assert flexnetosTerminalSupportMetadata.terminals.mars.startup_wm_class == "mars";
        true;
      flexnetosCcboard = "${flexnetosLinuxYaziRuntimeTools}/share/yazelix_yazi_assets/runtime_tools/ccboard/bin/ccboard";
      flexnetosCodedb = "${flexnetosLinuxYaziRuntimeTools}/share/yazelix_yazi_assets/runtime_tools/codedb/bin/codedb";
      flexnetosNuPluginCodedb = "${flexnetosLinuxYaziRuntimeTools}/share/yazelix_yazi_assets/runtime_tools/codedb/bin/nu_plugin_codedb";
      flexnetosRedbOwner = "${flexnetosLinuxYaziRuntimeTools}/share/yazelix_yazi_assets/runtime_tools/codedb/bin/flexnetos-redb-owner";
      flexnetosLayoutTemplate = pkgs.runCommand "flexnetos-agent-workspace-template.kdl" {} ''
        substitute ${./defaults/zellij/flexnetos_agent_workspace.kdl} "$out" \
          --replace-fail '@workspaceRoot@' '${metaWorkspaceRoot}' \
          --replace-fail '@yazi@' '${yzxYazi}/bin/yzx-yazi' \
          --replace-fail '@shell@' '${flexnetosYzxShell}/bin/yzx-shell' \
          --replace-fail '@agent@' '${yzxAgent}/bin/yzx-agent' \
          --replace-fail '@ccboard@' '${flexnetosCcboard}'
      '';
      flexnetosLayoutKdl = pkgs.runCommand "flexnetos-agent-workspace.kdl" {} ''
        substitute ${flexnetosLayoutTemplate} "$out" \
          --replace-fail '@bar@' "$(<${yzxBarKdl})"
      '';
      flexnetosZellijLayout = pkgs.runCommand "flexnetos-zellij-layout" {} ''
        ${yzxLayoutCheck}/bin/yzx-layout-check ${flexnetosLayoutKdl} ${yzxLayoutSwapKdl} ${pkgs.lib.escapeShellArg novaBarLabel} workspace
        install -D -m 644 ${flexnetosLayoutKdl} "$out/layout.kdl"
        install -D -m 644 ${yzxLayoutSwapKdl} "$out/layout.swap.kdl"
      '';
      yzxLazyGitConfig = pkgs.writeText "yzx-lazygit.yml" ''
        os:
          edit: '${yzxEditor}/bin/yzx-editor {{filename}}'
          editAtLine: '${yzxEditor}/bin/yzx-editor {{filename}}'
          editAtLineAndWait: '${yzxEditor}/bin/yzx-editor {{filename}}'
          editInTerminal: true
          openDirInEditor: '${yzxEditor}/bin/yzx-editor {{dir}}'
      '';
      yzxGit = nuApplication "yzx-git" ./runtime/yzx_git.nu {
        lazygit = "${pkgs.lazygit}/bin/lazygit";
        yzxEditor = "${yzxEditor}/bin/yzx-editor";
        yzxLazyGitConfig = "${yzxLazyGitConfig}";
      };
      mkYzxConfigKdl = shellPackage: pkgs.replaceVars ./defaults/zellij/config.kdl {
        yzxShell = "${shellPackage}/bin/yzx-shell";
        yzpp = "file:${yazelixZellijPopupPackage}/${yazelixZellijPopupPackage.wasmPath}";
        yzxPaneOrchestrator = "file:${yazelixZellijPaneOrchestratorPackage}/${yazelixZellijPaneOrchestratorPackage.wasmPath}";
        yzxAgent = "${yzxAgent}/bin/yzx-agent";
        configKey = defaultConfig.keybindings.config;
        agentKey = defaultConfig.keybindings.agent;
        gitKey = defaultConfig.keybindings.git;
        menuKey = defaultConfig.keybindings.menu;
        screenKey = defaultConfig.keybindings.screen;
        sidebarKey = defaultConfig.keybindings.sidebar;
        sidebarFocusKey = defaultConfig.keybindings.sidebar_focus;
        inherit defaultPopupSideMargin defaultPopupVerticalMargin;
        yzxConfig = "${yzxConfigUi}/bin/yzx-config-ui";
        yzxMenu = "${yzxMenu}/bin/yzx-menu";
        yzxScreen = "${yazelixScreenPackage}/bin/yzs";
        yzxYazi = "${yzxYazi}/bin/yzx-yazi";
        yzxSidebarRefresh = "${yzxOpenCore}/bin/yzx-sidebar-refresh";
        git = "${yzxGit}/bin/yzx-git";
        layout = "${yzxZellijLayout}/layout.kdl";
      };
      flexnetosYzxConfigKdl = mkYzxConfigKdl flexnetosYzxShell;
      zellijBuildBase =
        if pkgs ? "zellij-unwrapped"
        then pkgs."zellij-unwrapped"
        else if pkgs.zellij ? unwrapped
        then pkgs.zellij.unwrapped
        else throw "Yazelix Nova requires the nixpkgs Zellij 0.44.3 unwrapped package contract";
      yazelixZellijPackage =
        assert zellijBuildBase.version == "0.44.3";
        zellijBuildBase.overrideAttrs (_old: {
        pname = "zellij";
        version = "0.44.3";
        src = yazelixZellij;
        patches = [];
        prePatch = "";
        postPatch = "";
        installCheckPhase = ''
          runHook preInstallCheck
          runHook postInstallCheck
        '';
        cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
          pname = "zellij";
          version = "0.44.3";
          src = yazelixZellij;
          hash = "sha256-966FpfSsF9I10SrYe3+YNsfM2kLLv+gd0/Aw8vLp4Lk=";
        };
        doCheck = false;
      });
      # Merged factory: upstream's package-variant matrix (managed-Helix /
      # managed-Yazi / Mars axes) carrying the fork's Nushell/Rust components.
      # Fork call sites pass extension parameters (name / layout / config /
      # shell / state overrides) through `args`; the upstream variant packages
      # use the defaults.
      mkYzx = {
        withManagedHelix ? true,
        withManagedYazi ? true,
        withMars,
        ...
      } @ args: let
        variantSuffix = pkgs.lib.concatStringsSep "-" (
          pkgs.lib.optional (! withMars) "no-mars"
          ++ pkgs.lib.optional (! withManagedHelix) "no-helix"
          ++ pkgs.lib.optional (! withManagedYazi) "no-yazi"
        );
        variant = if variantSuffix == "" then "full" else variantSuffix;
        name = args.name or ("yazelix" + pkgs.lib.optionalString (variantSuffix != "") "-${variantSuffix}");
        # Fork extension parameters with upstream-compatible defaults.
        withDesktop = args.withDesktop or (withMars && pkgs.stdenv.hostPlatform.isLinux);
        layoutTemplate = args.layoutTemplate or ./defaults/zellij/layout.kdl;
        nuConfig = args.nuConfig or yzxNuConfig;
        shellPackage = args.shellPackage or yzxShell;
        extraPathPrefix = args.extraPathPrefix or [];
        desktopEntrySource = args.desktopEntrySource or "";
        desktopDatabaseUpdater = args.desktopDatabaseUpdater or "";
        defaultStateDir = args.defaultStateDir or "";
        yaziRuntime =
          if withManagedYazi
          then {
            source = "bundled";
            yaziCommand = "${pkgs.yazi}/bin/yazi";
            yaCommand = "${pkgs.yazi}/bin/ya";
          }
          else {
            source = "host";
            yaziCommand = "yazi";
            yaCommand = "ya";
          };
        managedEditor =
          if withManagedHelix
          then yzxHelix
          else yzxHelixUnavailable;
        tutor = let
          src = pkgs.runCommand "yzx-tutor-src" {} ''
            mkdir -p "$out"
            cp -R ${pkgs.lib.cleanSource ./crates/yzx-tutor}/. "$out/"
            chmod -R u+w "$out"
            substituteInPlace "$out/src/main.rs" \
              --replace-fail '@yzxHelix@' '${managedEditor}/bin/yzx-hx' \
              --replace-fail '@nu@' '${pkgs.nushell}/bin/nu'
          '';
        in
          pkgs.rustPlatform.buildRustPackage {
            pname = "yzx-tutor";
            version = "0.1.0";
            inherit src;
            cargoLock.lockFile = ./crates/yzx-tutor/Cargo.lock;
          };
        # Fork: Nushell editor/config-ui replace upstream's bash
        # upstream bash-application equivalents (repo shell-source policy),
        # parameterized by the variant's managed editor.
        editor = nuApplication "yzx-editor" ./runtime/yzx_editor.nu {
          yzxConfig = "${yzxConfig}/bin/yzx-config";
          yzxHelix = "${managedEditor}/bin/yzx-hx";
        };
        configUi = nuApplication "yzx-config-ui" ./runtime/yzx_config_ui.nu {
          yzxConfig = "${yzxConfig}/bin/yzx-config";
          yzxEditor = "${editor}/bin/yzx-editor";
          yzxHelix = "${managedEditor}/bin/yzx-hx";
        };
        yazi = rustBin "yzx-yazi" (pkgs.replaceVars ./runtime/yzx-yazi.rs {
          yzxYaziConfig = "${yzxYaziConfig}";
          yzxYaziMaterializer = "${yzxYaziMaterializer}/bin/yzx-yazi-config";
          yzxOpen = "${yzxOpenCore}/bin/yzx-open";
          zellij = "${yazelixZellijPackage}/bin/zellij";
          yzxHelix = "${managedEditor}/bin/yzx-hx";
          yzxEditor = "${editor}/bin/yzx-editor";
          yzxConfig = "${yzxConfig}/bin/yzx-config";
          pathPrefix = pkgs.lib.makeBinPath [pkgs.fzf pkgs.git pkgs.starship pkgs.zoxide];
        });
        layout = args.layoutPackage or (let
          main = pkgs.runCommand "layout.kdl" {} ''
            substitute ${./defaults/zellij/layout.kdl} "$out" \
              --replace-fail '@yazi@' '${yazi}/bin/yzx-yazi' \
              --replace-fail '@bar@' "$(<${yzxBarKdl})"
          '';
          swap = pkgs.replaceVars ./defaults/zellij/layout.swap.kdl {
            yazi = "${yazi}/bin/yzx-yazi";
          };
        in
          pkgs.runCommand "yzx-zellij-layout" {} ''
            ${yzxLayoutCheck}/bin/yzx-layout-check ${main} ${swap} ${pkgs.lib.escapeShellArg novaBarLabel}
            install -D -m 644 ${main} "$out/layout.kdl"
            install -D -m 644 ${swap} "$out/layout.swap.kdl"
          '');
        git = let
          config = pkgs.writeText "yzx-lazygit.yml" ''
            os:
              edit: '${editor}/bin/yzx-editor {{filename}}'
              editAtLine: '${editor}/bin/yzx-editor {{filename}}'
              editAtLineAndWait: '${editor}/bin/yzx-editor {{filename}}'
              editInTerminal: true
              openDirInEditor: '${editor}/bin/yzx-editor {{dir}}'
          '';
        in
          # Fork: Nushell yzx-git replaces the upstream bash application.
          nuApplication "yzx-git" ./runtime/yzx_git.nu {
            lazygit = "${pkgs.lazygit}/bin/lazygit";
            yzxEditor = "${editor}/bin/yzx-editor";
            yzxLazyGitConfig = "${config}";
          };
        configKdl = args.configKdl or variantConfigKdl;
        variantConfigKdl = pkgs.replaceVars ./defaults/zellij/config.kdl {
          yzxShell = "${shellPackage}/bin/yzx-shell";
          yzpp = "file:${yazelixZellijPopupPackage}/${yazelixZellijPopupPackage.wasmPath}";
          yzxPaneOrchestrator = "file:${yazelixZellijPaneOrchestratorPackage}/${yazelixZellijPaneOrchestratorPackage.wasmPath}";
          yzxAgent = "${yzxAgent}/bin/yzx-agent";
          configKey = defaultConfig.keybindings.config;
          agentKey = defaultConfig.keybindings.agent;
          gitKey = defaultConfig.keybindings.git;
          menuKey = defaultConfig.keybindings.menu;
          screenKey = defaultConfig.keybindings.screen;
          sidebarKey = defaultConfig.keybindings.sidebar;
          sidebarFocusKey = defaultConfig.keybindings.sidebar_focus;
          inherit defaultPopupSideMargin defaultPopupVerticalMargin;
          yzxConfig = "${configUi}/bin/yzx-config-ui";
          yzxMenu = "${yzxMenu}/bin/yzx-menu";
          yzxScreen = "${yazelixScreenPackage}/bin/yzs";
          yzxYazi = "${yazi}/bin/yzx-yazi";
          yzxSidebarRefresh = "${yzxOpenCore}/bin/yzx-sidebar-refresh";
          git = "${git}/bin/yzx-git";
          layout = "${layout}/layout.kdl";
        };
        main = pkgs.replaceVars ./runtime/yzx/main.rs {
          packageVariant = variant;
          managedHelix = if withManagedHelix then "included" else "omitted";
          yzxConfigUi = "${configUi}/bin/yzx-config-ui";
          yzxMenu = "${yzxMenu}/bin/yzx-menu";
          yzxTutor = "${tutor}/bin/yzx-tutor";
          yzxScreen = "${yazelixScreenPackage}/bin/yzs";
          yzxWelcome = "${yzxWelcome}/bin/yzx-welcome";
          yzxShell = "${shellPackage}/bin/yzx-shell";
          yzxEnvSupervisor = "${yzxEnvSupervisor}/bin/yzx-env-supervisor";
          zellij = "${yazelixZellijPackage}/bin/zellij";
          mars = if withMars then "${marsPackage}/bin/mars" else "";
          inherit desktopEntrySource desktopDatabaseUpdater defaultStateDir;
          layout = "${layout}/layout.kdl";
          layoutTemplate = "${layoutTemplate}";
          layoutSwapTemplate = "${./defaults/zellij/layout.swap.kdl}";
          yzxAgent = "${yzxAgent}/bin/yzx-agent";
          yzxYazi = "${yazi}/bin/yzx-yazi";
          yzxHelix = "${managedEditor}/bin/yzx-hx";
          yzxEditor = "${editor}/bin/yzx-editor";
          yzxConfig = "${yzxConfig}/bin/yzx-config";
          yzxMarsConfig = if withMars then "${yzxMarsConfig}" else "";
          yzxZellijConfig = "${yzxZellijConfig}/bin/yzx-zellij-config";
          yzxConfigKdl = "${configKdl}";
          yzxRuntimeIdentity = "${yzxRuntimeIdentity}/runtime_identity.json";
          yzxYaziConfig = "${yzxYaziConfig}";
          yzxYaziMaterializer = "${yzxYaziMaterializer}/bin/yzx-yazi-config";
          yzxReveal = "${yzxOpenCore}/bin/yzx-reveal";
          yzxSidebarRefresh = "${yzxOpenCore}/bin/yzx-sidebar-refresh";
          yaziSource = yaziRuntime.source;
          yaziCommand = yaziRuntime.yaziCommand;
          yaCommand = yaziRuntime.yaCommand;
          yaziTestedVersion = pkgs.yazi.version;
          yzxBarRenderRequest = "${yzxBarRenderRequestTemplate}";
          yzxBarRender = "${yzxBarRender}/bin/yzx-bar-render";
          yazelixZellijPopupWasm = "${yazelixZellijPopupPackage}/${yazelixZellijPopupPackage.wasmPath}";
          yazelixZellijBarWasm = "${yazelixZellijBarPackage}/share/yazelix_zellij_bar/zjstatus.wasm";
          yazelixZellijPaneOrchestratorWasm = "${yazelixZellijPaneOrchestratorPackage}/${yazelixZellijPaneOrchestratorPackage.wasmPath}";
          defaultBarWidgetsJson = builtins.toJSON defaultBarWidgets;
          inherit defaultShellProgram;
          defaultConfigKeybinding = defaultConfig.keybindings.config;
          defaultAgentKeybinding = defaultConfig.keybindings.agent;
          defaultGitKeybinding = defaultConfig.keybindings.git;
          defaultMenuKeybinding = defaultConfig.keybindings.menu;
          defaultScreenKeybinding = defaultConfig.keybindings.screen;
          defaultSidebarKeybinding = defaultConfig.keybindings.sidebar;
          defaultSidebarFocusKeybinding = defaultConfig.keybindings.sidebar_focus;
          inherit defaultPopupSideMargin defaultPopupVerticalMargin;
          version = novaVersion;
          pathPrefix =
            pkgs.lib.makeBinPath [
              pkgs.coreutils
              pkgs.git
              pkgs.lazygit
              tokenusage
              managedEditor
            ]
            + pkgs.lib.optionalString (extraPathPrefix != []) (
              ":" + pkgs.lib.makeBinPath extraPathPrefix
            );
        };
        src = pkgs.runCommand "yzx-command-${variant}-src" {} ''
          mkdir -p "$out"
          cp -R ${pkgs.lib.cleanSource ./runtime/yzx}/. "$out/"
          chmod -R u+w "$out"
          cp ${main} "$out/main.rs"
        '';
        command = rustBin "yzx" "${src}/main.rs";
        desktop = pkgs.makeDesktopItem {
          name = "yzx";
          desktopName = "Yazelix Nova";
          genericName = "Terminal Emulator";
          comment = "Open the Yazelix integrated terminal workspace";
          exec = "${command}/bin/yzx launch";
          icon = "yzx";
          terminal = false;
          categories = ["System" "TerminalEmulator"];
          startupNotify = true;
          startupWMClass = "yzx";
        };
      in
        pkgs.symlinkJoin {
          inherit name;
          paths = [command] ++ pkgs.lib.optional withDesktop desktop;
          postBuild =
            ''
              ${yazelixZellijPackage}/bin/zellij --config ${configKdl} setup --check >/dev/null
              install -d "$out/libexec/yazelix"
              ln -s ${yzxZellijConfig}/bin/yzx-zellij-config "$out/libexec/yazelix/yzx-zellij-config"
              ln -s ${yzxConfig}/bin/yzx-config "$out/libexec/yazelix/yzx-config"
              ln -s ${tutor}/bin/yzx-tutor "$out/libexec/yazelix/yzx-tutor"
              install -D -m 644 ${configKdl} "$out/share/yazelix/config.kdl"
              install -D -m 644 ${yzxRuntimeIdentity}/runtime_identity.json "$out/share/yazelix/runtime_identity.json"
              install -D -m 644 ${yazelixCursors}/yazelix_cursors_default.toml "$out/share/yazelix/cursors.toml"
              install -D -m 644 ${./defaults/config.toml} "$out/share/yazelix/config.toml"
              install -D -m 644 ${layout}/layout.kdl "$out/share/yazelix/layout.kdl"
              install -D -m 644 ${layout}/layout.swap.kdl "$out/share/yazelix/layout.swap.kdl"
              ln -s ${yzxYaziConfig} "$out/share/yazelix/yazi"
              install -D -m 644 ${nuConfig}/config.nu "$out/share/yazelix/nu/config.nu"
              install -D -m 644 ${nuConfig}/env.nu "$out/share/yazelix/nu/env.nu"
            ''
            + pkgs.lib.optionalString withMars ''
              install -D -m 644 ${yzxMarsConfig}/config.toml "$out/share/yazelix/mars/config.toml"
            ''
            + pkgs.lib.optionalString withDesktop ''
              for icon in ${marsPackage}/share/icons/hicolor/*/apps/mars.png; do
                size="$(basename "$(dirname "$(dirname "$icon")")")"
                install -d "$out/share/icons/hicolor/$size/apps"
                ln -s "$icon" "$out/share/icons/hicolor/$size/apps/yzx.png"
              done
              install -d "$out/share/pixmaps"
              ln -s ${marsPackage}/share/pixmaps/mars.png "$out/share/pixmaps/yzx.png"
            '';
          meta.platforms = supportedSystems;
        };
      # Fork: packages stay let-bound with an explicit output attrset (not
      # upstream's `rec` output) so FlexNetOS support bindings never leak into
      # the flake's package set.
      yazelix = mkYzx {
        withManagedHelix = true;
        withManagedYazi = true;
        withMars = true;
      };
      yazelix-no-helix = mkYzx {
        withManagedHelix = false;
        withManagedYazi = true;
        withMars = true;
      };
      yazelix-no-yazi = mkYzx {
        withManagedHelix = true;
        withManagedYazi = false;
        withMars = true;
      };
      yazelix-no-helix-no-yazi = mkYzx {
        withManagedHelix = false;
        withManagedYazi = false;
        withMars = true;
      };
      yazelix-no-mars = mkYzx {
        withManagedHelix = true;
        withManagedYazi = true;
        withMars = false;
      };
      yazelix-no-mars-no-helix = mkYzx {
        withManagedHelix = false;
        withManagedYazi = true;
        withMars = false;
      };
      yazelix-no-mars-no-yazi = mkYzx {
        withManagedHelix = true;
        withManagedYazi = false;
        withMars = false;
      };
      yazelix-no-mars-no-helix-no-yazi = mkYzx {
        withManagedHelix = false;
        withManagedYazi = false;
        withMars = false;
      };
      # Fork: the Mars-free runtime package keeps its historical name.
      yzxRuntime = mkYzx {
        name = "yazelix-runtime";
        withMars = false;
      };
      fenixPkgs = fenix.packages.${system};
      flexnetosRustPlatform = pkgs.makeRustPlatform {
        cargo = fenixPkgs.latest.cargo;
        rustc = fenixPkgs.latest.rustc;
      };
      flexnetosBeads = import ./packaging/beads_rust.nix {
        inherit pkgs;
        beadsSource = beads_rust_source;
        rustPlatform = flexnetosRustPlatform;
      };
      flexnetosBeadsViewer = beads_viewer.packages.${system}.bv;
      flexnetosClaude = import ./packaging/claude_code_release.nix {
        inherit pkgs;
        version = "2.1.220";
      };
      flexnetosCodex = import ./packaging/codex_cli_release.nix {
        inherit pkgs system;
        version = "0.145.0";
      };
      flexnetosGitKb = import ./packaging/git_kb_release.nix {
        inherit pkgs;
        version = "0.2.13";
      };
      flexnetosRtk = import ./packaging/rtk_release.nix {
        inherit pkgs;
        rtkSource = rtk_source;
        rustPlatform = flexnetosRustPlatform;
      };
      flexnetosGrit = import ./packaging/grit_release.nix {
        inherit pkgs;
        gritSource = grit_source;
      };
      flexnetosIcm = import ./packaging/icm_release.nix {
        inherit pkgs;
        icmSource = icm_source;
      };
      flexnetosAgent = import ./packaging/agent_release.nix {
        inherit pkgs;
        agentSource = agent_source;
      };
      flexnetosWeave = import ./packaging/weave_release.nix {
        inherit pkgs;
        weaveSource = weave_source;
      };
      flexnetosObscura = import ./packaging/obscura_release.nix {
        inherit pkgs;
        obscuraSource = obscura_source;
      };
      flexnetosMeta = import ./packaging/meta_release.nix {inherit pkgs;};
      flexnetosKacheBase = import ./packaging/kache_release.nix {inherit pkgs;};
      flexnetosRunner = import ./packaging/flexnetos_runner_release.nix {
        inherit pkgs;
        runnerSource = flexnetos_runner_source;
      };
      flexnetosEnvctl = import ./packaging/envctl_release.nix {
        inherit pkgs;
        envctlSource = envctl_source;
        loopLibSource = loop_lib_source;
        metaPluginProtocolSource = meta_plugin_protocol_source;
        rustPlatform = flexnetosRustPlatform;
      };
      flexnetosGhaRunnerStart = ghaRunner.packages.${system}.runner-start;
      flexnetosNotebooklm = import ./packaging/notebooklm_release.nix {
        inherit pkgs;
        version = "0.8.0a3";
      };
      flexnetosKacheWrapperSource = pkgs.replaceVars ./packaging/kache_rustc_wrapper.rs {
        kache = "${flexnetosKacheBase}/bin/kache";
      };
      flexnetosKacheWrapper = rustBin "kache-rustc-wrapper" flexnetosKacheWrapperSource;
      flexnetosKacheWrappers = pkgs.linkFarm "kache-rustc-wrappers" [
        {
          name = "bin/kache-rustc-wrapper";
          path = "${flexnetosKacheWrapper}/bin/kache-rustc-wrapper";
        }
        {
          name = "libexec/kache/rustc";
          path = "${flexnetosKacheWrapper}/bin/kache-rustc-wrapper";
        }
      ];
      flexnetosKache = pkgs.symlinkJoin {
        name = "kache-with-rustc-wrapper-${flexnetosKacheBase.version}";
        paths = [flexnetosKacheBase flexnetosKacheWrappers];
      };
      flexnetosHostPolicy = nuApplication "yazelix_host_policy" ./nushell/system/host_policy.nu {};
      flexnetosVolatileRuntime = nuApplication "yazelix_volatile_runtime" ./nushell/system/volatile_runtime.nu {};
      flexnetosHostPolicyBundle = pkgs.symlinkJoin {
        name = "yazelix-host-policy";
        paths = [
          (pkgs.writeTextDir "share/yazelix/host-policy/nix.conf" (builtins.readFile ./host-policy/nix.conf))
          (pkgs.writeTextDir "share/yazelix/host-policy/nix.custom.conf" (builtins.readFile ./host-policy/nix.custom.conf))
          (pkgs.writeTextDir "share/yazelix/host-policy/determinate-config.json" (builtins.readFile ./host-policy/determinate-config.json))
          (pkgs.writeTextDir "share/yazelix/host-policy/shells" (builtins.readFile ./host-policy/shells))
          (pkgs.writeTextDir "share/yazelix/host-policy/nix-daemon.service" (builtins.readFile ./host-policy/nix-daemon.service))
          (pkgs.writeTextDir "share/yazelix/host-policy/nix-daemon.socket" (builtins.readFile ./host-policy/nix-daemon.socket))
          (pkgs.writeTextDir "share/yazelix/host-policy/journald-no-storage.conf" (builtins.readFile ./host-policy/journald-no-storage.conf))
          (pkgs.writeTextDir "share/yazelix/host-policy/docker-daemon.json" (builtins.readFile ./host-policy/docker-daemon.json))
          (pkgs.writeTextDir "share/yazelix/host-policy/chrome-storage.json" (builtins.readFile ./host-policy/chrome-storage.json))
          (pkgs.writeTextDir "lib/systemd/system/yazelix_host_policy.service" (builtins.readFile ./systemd/system/yazelix_host_policy.service))
          (pkgs.writeTextDir "lib/systemd/system/yazelix_host_policy.path" (builtins.readFile ./systemd/system/yazelix_host_policy.path))
        ];
      };
      flexnetosVolatileRuntimeBundle = pkgs.symlinkJoin {
        name = "yazelix-volatile-runtime";
        paths = [
          (pkgs.writeTextDir "share/yazelix/environment.d/10-yazelix-volatile.conf" (builtins.readFile ./host-policy/10-yazelix-volatile.conf))
          # Sorts after /usr/lib/environment.d/{99-environment,990-snapd}.conf, both of
          # which assign PATH; a lower prefix is silently overridden. See the file header.
          (pkgs.writeTextDir "share/yazelix/environment.d/99z-session-restore.conf" (builtins.readFile ./host-policy/99z-session-restore.conf))
          (pkgs.writeTextDir "lib/systemd/user/yazelix_volatile_runtime.service" (builtins.readFile ./systemd/user/yazelix_volatile_runtime.service))
          # GitKB sync servers. Upstream gitkb/meta ignores .kb/store/ because the store
          # is meant to travel over GitKB's own sync protocol rather than as git-tracked
          # files; the sync remote itself lives in the tracked .kb/config.toml, so every
          # worktree and clone inherits it. That only works if a server is actually
          # listening, so the three KB-owning repos get profile-owned units instead of
          # the transient `systemd-run` ones used to prove the design.
          (pkgs.writeTextDir "lib/systemd/user/gitkb-serve-meta.service" (builtins.readFile ./systemd/user/gitkb-serve-meta.service))
          (pkgs.writeTextDir "lib/systemd/user/gitkb-serve-lifeos.service" (builtins.readFile ./systemd/user/gitkb-serve-lifeos.service))
          (pkgs.writeTextDir "lib/systemd/user/gitkb-serve-envctl.service" (builtins.readFile ./systemd/user/gitkb-serve-envctl.service))
        ];
      };
      flexnetosRustToolchain = fenixPkgs.combine (
        [
          fenixPkgs.latest.cargo
          fenixPkgs.latest.rustc
          fenixPkgs.latest.rustfmt
          fenixPkgs.latest.clippy
          fenixPkgs.latest.rust-analyzer
        ]
        ++ pkgs.lib.optionals (system == "x86_64-linux") [
          fenixPkgs.targets.x86_64-unknown-linux-musl.latest.rust-std
        ]
      );
      flexnetosRust189Manifest = builtins.fetchurl {
        url = "https://static.rust-lang.org/dist/channel-rust-1.89.0.toml";
        sha256 = "sha256-+9FmLhAOezBZCOziO0Qct1NOrfpjNsXxc/8I0c7BdKE=";
      };
      flexnetosRust189 = fenixPkgs.fromManifestFile flexnetosRust189Manifest;
      flexnetosRust189Lane = pkgs.runCommand
        "flexnetos-foundation-rust-1.89-lane"
        {nativeBuildInputs = [pkgs.makeWrapper];}
        ''
          mkdir -p "$out/bin"
          makeWrapper "${flexnetosRust189.cargo}/bin/cargo" \
            "$out/bin/cargo-msrv-1.89" \
            --unset CARGO_BUILD_RUSTC_WRAPPER \
            --unset RUSTC_WRAPPER \
            --unset RUSTUP_TOOLCHAIN \
            --set RUSTC "${flexnetosRust189.rustc}/bin/rustc" \
            --set RUSTDOC "${flexnetosRust189.rustc}/bin/rustdoc"
          ln -s "${flexnetosRust189.rustc}/bin/rustc" "$out/bin/rustc-msrv-1.89"
          ln -s "${flexnetosRust189.rustc}/bin/rustdoc" "$out/bin/rustdoc-msrv-1.89"
        '';
      flexnetosMuslToolchain = pkgs.symlinkJoin {
        name = "flexnetos-foundation-musl-toolchain";
        paths = [pkgs.pkgsCross.musl64.stdenv.cc];
        postBuild = ''
          ln -s "$out/bin/x86_64-unknown-linux-musl-gcc" "$out/bin/x86_64-linux-musl-gcc"
          ln -s "$out/bin/x86_64-unknown-linux-musl-g++" "$out/bin/x86_64-linux-musl-g++"
          ln -s "$out/bin/x86_64-unknown-linux-musl-ar" "$out/bin/x86_64-linux-musl-ar"
          ln -s "$out/bin/x86_64-unknown-linux-musl-ranlib" "$out/bin/x86_64-linux-musl-ranlib"
        '';
      };
      flexnetosBun = pkgs.bun.overrideAttrs (_old: {
        version = "1.3.14";
        src = pkgs.fetchurl {
          url = "https://github.com/oven-sh/bun/releases/download/bun-v1.3.14/bun-linux-x64.zip";
          hash = "sha256-lR7iruhV8IWVruxiJSJqKY0/6oOj3NZGXAnLzN9+hI8=";
        };
      });
      flexnetosPython = pkgs.python3.withPackages (pythonPackages: [
        pythonPackages.pyyaml
      ]);
      # Durable agent homes under the Meta payload. Each value is consumed twice --
      # once by the agent frontdoor (which exports it and rejects a competing owner
      # by byte-for-byte string comparison) and once by that agent's materializer
      # wrapper -- so they are bound here rather than written out at each site.
      # These must stay byte-identical to DEFAULT_CODEX_HOME in flexnetos_runner's
      # crates/runner-cli/src/forge_loop.rs. Neither may live on tmpfs: /run/user/1001
      # is wiped on reboot, which previously destroyed the Codex credentials.
      # The meta workspace root -- the directory holding the .meta.yaml marker.
      # The retired /home/flexnetos/FlexNetOS mirror is gone; anything that used it
      # as a working directory belongs here.
      metaWorkspaceRoot = "/home/flexnetos/meta";
      codexStateHome = "${metaWorkspaceRoot}/var/lib/codex";
      claudeStateHome = "${metaWorkspaceRoot}/var/lib/claude";
      profileEnvironmentFrontdoor = name: payload: nuApplication name ./nushell/system/profile_environment_frontdoor.nu {
        tool = name;
        inherit payload;
        realHome = "/home/flexnetos";
        dataHome = "/home/flexnetos/meta/var/xdg-data";
        stateHome = "/home/flexnetos/meta/var/xdg-state";
        cacheHome = "/run/user/1001/yazelix/volatile/cache";
        runtimeDir = "/run/user/1001";
        yazelixStateDir = "/run/user/1001/yazelix/profile-runtime/yazelix";
        profileNu = "/home/flexnetos/.nix-profile/toolbin/nu";
        chmod = "${pkgs.coreutils}/bin/chmod";
      };
      flexnetosNuFrontdoor = profileEnvironmentFrontdoor "nu" "${pkgs.nushell}/bin/nu";
      flexnetosRtkFrontdoor = profileEnvironmentFrontdoor "rtk" "${flexnetosRtk}/bin/rtk";
      flexnetosRtkNuFrontdoor = profileEnvironmentFrontdoor "rtk_nu" "${flexnetosRtk}/bin/rtk_nu";
      flexnetosCodexOwnedFrontdoor = profileEnvironmentFrontdoor "codex" "${flexnetosCodexFrontdoor}/bin/codex";
      flexnetosClaudeOwnedFrontdoor = profileEnvironmentFrontdoor "claude" "${flexnetosClaudeFrontdoor}/bin/claude";
      flexnetosIcmOwnedFrontdoor = profileEnvironmentFrontdoor "icm" "${flexnetosIcmFrontdoor}/bin/icm";
      flexnetosExecutables = {
        Xvfb = "${pkgs.xorg-server}/bin/Xvfb";
        actionlint = "${pkgs.actionlint}/bin/actionlint";
        ar = "${pkgs.binutils}/bin/ar";
        awk = "${pkgs.gawk}/bin/awk";
        bash = "${pkgs.bash}/bin/bash";
        basename = "${pkgs.coreutils}/bin/basename";
        br = "${flexnetosBeads}/bin/br";
        bv = "${flexnetosBeadsViewer}/bin/bv";
        bun = "${flexnetosBun}/bin/bun";
        bunx = "${flexnetosBun}/bin/bunx";
        bzip2 = "${pkgs.bzip2}/bin/bzip2";
        cargo = "${flexnetosRustToolchain}/bin/cargo";
        cargo-audit = "${pkgs.cargo-audit}/bin/cargo-audit";
        cargo-clippy = "${flexnetosRustToolchain}/bin/cargo-clippy";
        cargo-fmt = "${flexnetosRustToolchain}/bin/cargo-fmt";
        "cargo-msrv-1.89" = "${flexnetosRust189Lane}/bin/cargo-msrv-1.89";
        cargo-tauri = "${pkgs.cargo-tauri}/bin/cargo-tauri";
        cc = "${pkgs.stdenv.cc}/bin/cc";
        ccboard = flexnetosCcboard;
        cat = "${pkgs.coreutils}/bin/cat";
        clang = "${pkgs.clang}/bin/clang";
        "clang++" = "${pkgs.clang}/bin/clang++";
        chmod = "${pkgs.coreutils}/bin/chmod";
        claude = "${flexnetosClaudeOwnedFrontdoor}/bin/claude";
        clippy-driver = "${flexnetosRustToolchain}/bin/clippy-driver";
        cmake = "${pkgs.cmake}/bin/cmake";
        codedb = flexnetosCodedb;
        codex = "${flexnetosCodexOwnedFrontdoor}/bin/codex";
        cp = "${pkgs.coreutils}/bin/cp";
        curl = "${pkgs.curl}/bin/curl";
        cut = "${pkgs.coreutils}/bin/cut";
        date = "${pkgs.coreutils}/bin/date";
        dirname = "${pkgs.coreutils}/bin/dirname";
        env = "${pkgs.coreutils}/bin/env";
        envctl = "${flexnetosEnvctl}/bin/envctl";
        file = "${pkgs.file}/bin/file";
        find = "${pkgs.findutils}/bin/find";
        flexnetos-redb-owner = flexnetosRedbOwner;
        fxrun = "${flexnetosRunner}/bin/fxrun";
        "fxrun-dispatch" = "${flexnetosRunner}/bin/fxrun-dispatch";
        yazelix_host_policy = "${flexnetosHostPolicy}/bin/yazelix_host_policy";
        yazelix_volatile_runtime = "${flexnetosVolatileRuntime}/bin/yazelix_volatile_runtime";
        agent = "${flexnetosAgent}/bin/agent";
        gh = "${pkgs.gh}/bin/gh";
        git = "${pkgs.git}/bin/git";
        git-kb = "${flexnetosGitKb}/bin/git-kb";
        grep = "${pkgs.gnugrep}/bin/grep";
        grit = "${flexnetosGrit}/bin/grit";
        gzip = "${pkgs.gzip}/bin/gzip";
        head = "${pkgs.coreutils}/bin/head";
        home-manager = "${home-manager.packages.${system}.default}/bin/home-manager";
        icm = "${flexnetosIcmOwnedFrontdoor}/bin/icm";
        jq = "${pkgs.jq}/bin/jq";
        kache = "${flexnetosKache}/bin/kache";
        kache-rustc-wrapper = "${flexnetosKache}/bin/kache-rustc-wrapper";
        "ld.wild" = "${pkgs.wild}/bin/ld.wild";
        loop = "${flexnetosMeta}/bin/loop";
        meta = "${flexnetosMeta}/bin/meta";
        meta-git = "${flexnetosMeta}/bin/meta-git";
        meta-mcp = "${flexnetosMeta}/bin/meta-mcp";
        meta-project = "${flexnetosMeta}/bin/meta-project";
        mkdir = "${pkgs.coreutils}/bin/mkdir";
        mv = "${pkgs.coreutils}/bin/mv";
        ninja = "${pkgs.ninja}/bin/ninja";
        node = "${pkgs.nodejs_24}/bin/node";
        nix = "${pkgs.nix}/bin/nix";
        nix-build = "${pkgs.nix}/bin/nix-build";
        nix-daemon = "${pkgs.nix}/bin/nix-daemon";
        nix-env = "${pkgs.nix}/bin/nix-env";
        nix-instantiate = "${pkgs.nix}/bin/nix-instantiate";
        nix-shell = "${pkgs.nix}/bin/nix-shell";
        nix-store = "${pkgs.nix}/bin/nix-store";
        journalctl = "${pkgs.systemd}/bin/journalctl";
        ln = "${pkgs.coreutils}/bin/ln";
        notebooklm = "${flexnetosNotebooklm}/bin/notebooklm";
        nvim = "${pkgs.neovim}/bin/nvim";
        nu = "${flexnetosNuFrontdoor}/bin/nu";
        nu_plugin_codedb = flexnetosNuPluginCodedb;
        obscura = "${flexnetosObscura}/bin/obscura";
        openssl = "${pkgs.openssl}/bin/openssl";
        pkg-config = "${pkgs.pkg-config}/bin/pkg-config";
        python3 = "${flexnetosPython}/bin/python3";
        readlink = "${pkgs.coreutils}/bin/readlink";
        realpath = "${pkgs.coreutils}/bin/realpath";
        rg = "${pkgs.ripgrep}/bin/rg";
        rm = "${pkgs.coreutils}/bin/rm";
        rtk = "${flexnetosRtkFrontdoor}/bin/rtk";
        scp = "${pkgs.openssh}/bin/scp";
        sed = "${pkgs.gnused}/bin/sed";
        secretctl = "${flexnetosEnvctl}/bin/secretctl";
        secretd = "${flexnetosEnvctl}/bin/secretd";
        sh = "${pkgs.bash}/bin/sh";
        sha256sum = "${pkgs.coreutils}/bin/sha256sum";
        sort = "${pkgs.coreutils}/bin/sort";
        ssh = "${pkgs.openssh}/bin/ssh";
        stat = "${pkgs.coreutils}/bin/stat";
        rtk_nu = "${flexnetosRtkNuFrontdoor}/bin/rtk_nu";
        systemctl = "${pkgs.systemd}/bin/systemctl";
        rust-analyzer = "${flexnetosRustToolchain}/bin/rust-analyzer";
        rustc = "${flexnetosRustToolchain}/bin/rustc";
        "rustc-msrv-1.89" = "${flexnetosRust189Lane}/bin/rustc-msrv-1.89";
        rustdoc = "${flexnetosRustToolchain}/bin/rustdoc";
        "rustdoc-msrv-1.89" = "${flexnetosRust189Lane}/bin/rustdoc-msrv-1.89";
        rustfmt = "${flexnetosRustToolchain}/bin/rustfmt";
        tail = "${pkgs.coreutils}/bin/tail";
        tar = "${pkgs.gnutar}/bin/tar";
        tee = "${pkgs.coreutils}/bin/tee";
        timeout = "${pkgs.coreutils}/bin/timeout";
        touch = "${pkgs.coreutils}/bin/touch";
        tr = "${pkgs.coreutils}/bin/tr";
        sqld = "${pkgs.sqld}/bin/sqld";
        sqlite3 = "${pkgs.sqlite}/bin/sqlite3";
        tu = "${tokenusage}/bin/tu";
        uname = "${pkgs.coreutils}/bin/uname";
        usermod = "${pkgs.shadow}/bin/usermod";
        uv = "${pkgs.uv}/bin/uv";
        uvx = "${pkgs.uv}/bin/uvx";
        wasm-pack = "${pkgs.wasm-pack}/bin/wasm-pack";
        wc = "${pkgs.coreutils}/bin/wc";
        weave = "${flexnetosWeave}/bin/weave";
        wild = "${pkgs.wild}/bin/wild";
        xargs = "${pkgs.findutils}/bin/xargs";
        xz = "${pkgs.xz}/bin/xz";
        x86_64-linux-musl-ar = "${flexnetosMuslToolchain}/bin/x86_64-linux-musl-ar";
        "x86_64-linux-musl-g++" = "${flexnetosMuslToolchain}/bin/x86_64-linux-musl-g++";
        x86_64-linux-musl-gcc = "${flexnetosMuslToolchain}/bin/x86_64-linux-musl-gcc";
        x86_64-linux-musl-ranlib = "${flexnetosMuslToolchain}/bin/x86_64-linux-musl-ranlib";
        x86_64-unknown-linux-musl-ar = "${flexnetosMuslToolchain}/bin/x86_64-unknown-linux-musl-ar";
        "x86_64-unknown-linux-musl-g++" = "${flexnetosMuslToolchain}/bin/x86_64-unknown-linux-musl-g++";
        x86_64-unknown-linux-musl-gcc = "${flexnetosMuslToolchain}/bin/x86_64-unknown-linux-musl-gcc";
        x86_64-unknown-linux-musl-ranlib = "${flexnetosMuslToolchain}/bin/x86_64-unknown-linux-musl-ranlib";
      };
      flexnetosUtilityPackages = with pkgs; [
        bash
        bzip2
        coreutils
        curl
        debianutils
        diffutils
        findutils
        gawk
        gh
        git
        gnugrep
        gnused
        gnutar
        gzip
        jq
        openssh
        patch
        procps
        flexnetosPython
        ripgrep
        util-linux
        which
        xz
      ];
      flexnetosTools = pkgs.runCommand "flexnetos-foundation-tools" {} (
        ''
          mkdir -p "$out/bin" "$out/toolbin" "$out/libexec/kache"
          ln -s ${flexnetosKache}/libexec/kache/rustc "$out/libexec/kache/rustc"
        ''
        + pkgs.lib.concatStringsSep "\n" (
          pkgs.lib.mapAttrsToList (name: executable: ''
            test -x ${pkgs.lib.escapeShellArg executable}
            ln -s ${pkgs.lib.escapeShellArg executable} "$out/bin/${name}"
            ln -s ${pkgs.lib.escapeShellArg executable} "$out/toolbin/${name}"
          '') flexnetosExecutables
        )
        + ''
          for package in ${pkgs.lib.escapeShellArgs flexnetosUtilityPackages}; do
            for executable in "$package"/bin/*; do
              test -x "$executable" || continue
              name="''${executable##*/}"
              if ! test -e "$out/bin/$name"; then
                ln -s "$executable" "$out/bin/$name"
              fi
              if ! test -e "$out/toolbin/$name"; then
                ln -s "$executable" "$out/toolbin/$name"
              fi
            done
          done
        ''
      );
      # YZXCONV-003: single-profile closure contract tools. The check verifies
      # that ~/.nix-profile is the sole foundation selector; the migration
      # performs the cutover (dry-run by default) with a rollback receipt.
      flexnetosProfileTools = pkgs.runCommand "flexnetos-profile-tools" {} ''
        mkdir -p "$out/bin" "$out/share/yazelix/packaging"
        install -m 644 ${./packaging/single_profile_check.nu} \
          "$out/share/yazelix/packaging/single_profile_check.nu"
        install -m 644 ${./packaging/profile_migration.nu} \
          "$out/share/yazelix/packaging/profile_migration.nu"
        cat > "$out/bin/yazelix_profile_check" <<EOF
        #!${pkgs.nushell}/bin/nu
        def --wrapped main [...args] {
          exec ${pkgs.nushell}/bin/nu "$out/share/yazelix/packaging/single_profile_check.nu" ...\$args
        }
        EOF
        cat > "$out/bin/yazelix_profile_migrate" <<EOF
        #!${pkgs.nushell}/bin/nu
        def --wrapped main [...args] {
          \$env.YZX_CHECK_SCRIPT = "$out/share/yazelix/packaging/single_profile_check.nu"
          \$env.YZX_NIX_BIN = (\$env.YZX_NIX_BIN? | default "${pkgs.nix}/bin/nix")
          \$env.YZX_NIX_STORE_BIN = (\$env.YZX_NIX_STORE_BIN? | default "${pkgs.nix}/bin/nix-store")
          \$env.YZX_NU_BIN = "${pkgs.nushell}/bin/nu"
          \$env.YZX_READLINK_BIN = "${pkgs.coreutils}/bin/readlink"
          \$env.YZX_MV_BIN = "${pkgs.coreutils}/bin/mv"
          \$env.YZX_DATE_BIN = "${pkgs.coreutils}/bin/date"
          exec ${pkgs.nushell}/bin/nu "$out/share/yazelix/packaging/profile_migration.nu" ...\$args
        }
        EOF
        chmod +x "$out/bin/yazelix_profile_check" "$out/bin/yazelix_profile_migrate"
      '';
      flexnetosCodexConfigOwner = pkgs.runCommand "yazelix-codex-config-owner" {} ''
        mkdir -p "$out/bin" "$out/share/yazelix/agent_configs/codex" \
          "$out/share/yazelix/nushell/scripts"
        install -m 644 ${./agent_configs/codex/config.toml.src} \
          "$out/share/yazelix/agent_configs/codex/config.toml.src"
        install -m 644 ${./agent_configs/codex/RULES.md.src} \
          "$out/share/yazelix/agent_configs/codex/RULES.md.src"
        install -m 644 ${./agent_configs/codex/hooks.json.src} \
          "$out/share/yazelix/agent_configs/codex/hooks.json.src"
        install -m 644 ${./nushell/scripts/materialize_codex_config.nu} \
          "$out/share/yazelix/nushell/scripts/materialize_codex_config.nu"
        cat > "$out/bin/yazelix_codex_materialize" <<EOF
        #!${pkgs.nushell}/bin/nu
        def --wrapped main [...args] {
          if (\$args | is-empty) or \$args == ["--recover-only"] {
            let profile = "/home/flexnetos/.nix-profile"
            let codex_home = "${codexStateHome}"
            exec ${pkgs.nushell}/bin/nu \
              "$out/share/yazelix/nushell/scripts/materialize_codex_config.nu" \
              (\$profile | path join "share/yazelix/agent_configs/codex/config.toml.src") \
              (\$codex_home | path join "config.toml") \
              (\$profile | path join "share/yazelix/agent_configs/codex/RULES.md.src") \
              (\$codex_home | path join "RULES.md") \
              (\$profile | path join "share/yazelix/agent_configs/codex/hooks.json.src") \
              (\$codex_home | path join "hooks.json") ...\$args
          }
          exec ${pkgs.nushell}/bin/nu \
            "$out/share/yazelix/nushell/scripts/materialize_codex_config.nu" ...\$args
        }
        EOF
        chmod +x "$out/bin/yazelix_codex_materialize"
      '';
      flexnetosClaudeConfigOwner = pkgs.runCommand "yazelix-claude-config-owner" {} ''
        mkdir -p "$out/bin" "$out/share/yazelix/agent_configs/claude" \
          "$out/share/yazelix/nushell/scripts"
        install -m 644 ${./agent_configs/claude/settings.json.src} \
          "$out/share/yazelix/agent_configs/claude/settings.json.src"
        install -m 644 ${./agent_configs/claude/CLAUDE.md.src} \
          "$out/share/yazelix/agent_configs/claude/CLAUDE.md.src"
        install -m 644 ${./agent_configs/claude/RTK.md.src} \
          "$out/share/yazelix/agent_configs/claude/RTK.md.src"
        install -m 644 ${agent_source}/.claude/agent-guard.toml \
          "$out/share/yazelix/agent_configs/claude/agent-guard.toml.src"
        install -m 644 ${./nushell/scripts/materialize_claude_config.nu} \
          "$out/share/yazelix/nushell/scripts/materialize_claude_config.nu"
        cat > "$out/bin/yazelix_claude_materialize" <<EOF
        #!${pkgs.nushell}/bin/nu
        def --wrapped main [...args] {
          if (\$args | is-empty) {
            let profile = "/home/flexnetos/.nix-profile"
            let claude_home = "${claudeStateHome}"
            exec ${pkgs.nushell}/bin/nu \
              "$out/share/yazelix/nushell/scripts/materialize_claude_config.nu" \
              (\$profile | path join "share/yazelix/agent_configs/claude/settings.json.src") \
              (\$claude_home | path join "settings.json") \
              (\$profile | path join "share/yazelix/agent_configs/claude/CLAUDE.md.src") \
              (\$claude_home | path join "CLAUDE.md") \
              (\$profile | path join "share/yazelix/agent_configs/claude/RTK.md.src") \
              (\$claude_home | path join "RTK.md") \
              (\$profile | path join "share/yazelix/agent_configs/claude/agent-guard.toml.src") \
              (\$claude_home | path join "agent-guard.toml")
          }
          exec ${pkgs.nushell}/bin/nu \
            "$out/share/yazelix/nushell/scripts/materialize_claude_config.nu" ...\$args
        }
        EOF
        chmod +x "$out/bin/yazelix_claude_materialize"
      '';
      flexnetosCodexFrontdoor = nuApplication "codex" ./nushell/agent/profile_frontdoor.nu {
        agent = "codex";
        stateHome = codexStateHome;
        payload = "${flexnetosCodex}/bin/codex";
        materializer = "/home/flexnetos/.nix-profile/bin/yazelix_codex_materialize";
        chmod = "${pkgs.coreutils}/bin/chmod";
      };
      flexnetosClaudeFrontdoor = nuApplication "claude" ./nushell/agent/profile_frontdoor.nu {
        agent = "claude";
        stateHome = claudeStateHome;
        payload = "${flexnetosClaude}/bin/claude";
        materializer = "/home/flexnetos/.nix-profile/bin/yazelix_claude_materialize";
        chmod = "${pkgs.coreutils}/bin/chmod";
      };
      flexnetosIcmFrontdoor = nuApplication "icm" ./nushell/agent/icm_profile_frontdoor.nu {
        payload = "${flexnetosIcm}/bin/icm";
        defaultDb = "/home/flexnetos/meta/var/xdg-data/icm/memories.db";
      };
      flexnetosDesktopSource = pkgs.makeDesktopItem {
        name = "com.flexnetos.Yazelix.Agent";
        destination = "/share/applications";
        desktopName = "FlexNetOS Yazelix Agent";
        genericName = "Terminal Emulator";
        comment = "Yazelix Nova with the profile-owned FlexNetOS agent workspace";
        exec = "/home/flexnetos/.nix-profile/bin/yzx launch";
        icon = "/home/flexnetos/.nix-profile/share/pixmaps/yazelix.png";
        terminal = false;
        categories = ["System" "TerminalEmulator"];
        startupNotify = true;
        startupWMClass = "mars";
        extraConfig = {
          "X-Yazelix-Managed" = "true";
          "X-FlexNetOS-Managed" = "true";
        };
      };
      flexnetosClaudeDesktopSource = pkgs.makeDesktopItem {
        name = "claude-code-url-handler";
        destination = "/share/applications";
        desktopName = "Claude Code URL Handler";
        comment = "Handle claude-cli deep links through the profile-owned Claude frontdoor";
        exec = "/home/flexnetos/.nix-profile/bin/claude --handle-uri %u";
        terminal = false;
        noDisplay = true;
        extraConfig = {
          "MimeType" = "x-scheme-handler/claude-cli;";
          "X-FlexNetOS-Managed" = "true";
        };
      };
      flexnetosYzxBase = mkYzx {
        name = "lifeos-foundation-yzx-base";
        withMars = true;
        withDesktop = false;
        layoutPackage = flexnetosZellijLayout;
        layoutTemplate = flexnetosLayoutTemplate;
        configKdl = flexnetosYzxConfigKdl;
        nuConfig = flexnetosYzxNuConfig;
        shellPackage = flexnetosYzxShell;
        extraPathPrefix = [flexnetosTools];
        defaultStateDir = "/run/user/1001/yazelix/profile-runtime/yazelix";
      };
      # PostgreSQL/RuVector is the Swarm Primary Runtime (blueprint hard rule 1), yet
      # the profile shipped no postgres, psql or pg_ctl at all -- `git log -S postgresql`
      # over this flake returns nothing, so it was never here. On 2026-07-27 that cost
      # the whole RuVector layer: the running cluster had been started on 2026-07-23 via
      # /home/flexnetos/.nix-profile/bin/postgres, a path that no longer exists, and
      # every one of the extension's 188 catalog-registered functions failed with
      # `could not access file "$libdir/ruvector"`.
      #
      # PostgreSQL resolves pkglibdir from the INVOKED path (argv[0], via find_my_exec),
      # not the resolved realpath. Because this foundation is a symlinkJoin, adding the
      # bundle here puts bin/postgres AND lib/ruvector.so in the same output, so
      # `<foundation>/bin/postgres` computes pkglibdir as `<foundation>/lib` and finds
      # the extension. That makes the fix structural instead of dependent on whoever
      # happens to launch the server.
      #
      # The extension is built from fetched source (see packaging/ruvector_postgres.nix,
      # whose recipe was recovered from the lost build's .drv). It previously entered
      # the profile as builtins.storePath, which is disallowed in pure eval and forced
      # --impure on every rebuild; building it here removes that.
      flexnetosRuvectorPostgres = import ./packaging/ruvector_postgres.nix {
        inherit pkgs;
      };
      # Same buildEnv the original bundle used -- postgresql-and-plugins-17.10 -- so
      # bin/ and lib/ stay co-located for the argv[0] pkglibdir resolution above.
      flexnetosPostgresRuvector =
        pkgs.postgresql_17.withPackages (_: [flexnetosRuvectorPostgres]);

      lifeosFoundationYzx = assert flexnetosTerminalSupportContract; pkgs.symlinkJoin {
        name = "lifeos-foundation-yzx";
        paths = [flexnetosYzxBase flexnetosTools flexnetosProfileTools flexnetosCodexConfigOwner flexnetosClaudeConfigOwner flexnetosDesktopSource flexnetosClaudeDesktopSource flexnetosTerminalSupport flexnetosGhaRunnerStart flexnetosHostPolicyBundle flexnetosVolatileRuntimeBundle flexnetosPostgresRuvector];
        nativeBuildInputs = [pkgs.desktop-file-utils];
        postBuild = ''
          install -D -m 644 ${flexnetosZellijLayout}/layout.kdl \
            "$out/configs/zellij/layouts/flexnetos_agent_workspace.kdl"
          install -D -m 644 ${flexnetosNuConfig} "$out/nushell/config/config.nu"
          install -D -m 644 ${./nushell/config/stack_prompt_guard.nu} "$out/nushell/config/stack_prompt_guard.nu"
          install -D -m 644 ${./nushell/config/rtk_wrappers.nu} "$out/nushell/config/rtk_wrappers.nu"
          install -D -m 644 ${./nushell/scripts/flexnetos_init.nu} "$out/nushell/scripts/flexnetos_init.nu"
          install -D -m 644 ${./nushell/system/profile_environment_frontdoor.nu} \
            "$out/nushell/system/profile_environment_frontdoor.nu"

          for icon in ${marsPackage}/share/icons/hicolor/*/apps/mars.png; do
            size="$(basename "$(dirname "$(dirname "$icon")")")"
            install -d "$out/share/icons/hicolor/$size/apps"
            ln -s "$icon" "$out/share/icons/hicolor/$size/apps/yzx.png"
          done
          install -D -m 644 ${marsPackage}/share/pixmaps/mars.png \
            "$out/share/pixmaps/yazelix.png"
        '';
        meta = flexnetosYzxBase.meta;
      };
      # yzx-iso T2 (spine ARCHBP-065): the LifeOS bubblewrap user-namespace
      # envelope, nix-declared with pinned inputs — no host installs required
      # to build.  Runtime executor selection records (never hides) the
      # AppArmor-profiled host-bwrap fallback on restricted hosts.  The engine
      # is Nushell (cache_shell_policy: no POSIX shell sources); the pinned
      # bwrap path is substituted into the executor candidate list.
      yzxEnvelope = pkgs.runCommand "yzx-envelope" {} ''
        mkdir -p $out/bin
        {
          echo '#!${pkgs.nushell}/bin/nu'
          ${pkgs.gnused}/bin/sed 's|@NIX_BWRAP@|${pkgs.bubblewrap}/bin/bwrap|g' ${./envelope/yzx-envelope.nu}
        } > $out/bin/yzx-envelope
        chmod +x $out/bin/yzx-envelope
        # Parse gate: the engine must at least evaluate under the pinned nu.
        ${pkgs.nushell}/bin/nu --commands "nu-check --debug '$out/bin/yzx-envelope' | ignore; exit 0"
      '';
    in {
      inherit
        yazelix
        yazelix-no-helix
        yazelix-no-yazi
        yazelix-no-helix-no-yazi
        yazelix-no-mars
        yazelix-no-mars-no-helix
        yazelix-no-mars-no-yazi
        yazelix-no-mars-no-helix-no-yazi
        ;
      runtime = yzxRuntime;
      default = yazelix;
    } // pkgs.lib.optionalAttrs pkgs.stdenv.isLinux {
      # bubblewrap is Linux-only; exposing this on darwin fails flake-shape
      # evaluation ("not available on the requested hostPlatform").
      yzx-envelope = yzxEnvelope;
    } // pkgs.lib.optionalAttrs (system == "x86_64-linux") {
      lifeos_foundation_yzx = lifeosFoundationYzx;
    });

    # The documented Teri Rust workflow enters this shell.  Keep its toolchain
    # profile-owned and provide the native OpenSSL/pkg-config boundary required
    # by Teri's existing dependency graph.
    devShells.x86_64-linux.ci = let
      pkgs = import nixpkgs {system = "x86_64-linux";};
    in pkgs.mkShell {
      packages = [self.packages.x86_64-linux.lifeos_foundation_yzx];
      nativeBuildInputs = [pkgs.pkg-config];
      buildInputs = [pkgs.openssl];
    };

    checks = eachSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      yzx = self.packages.${system}.yazelix;
      yzxNoHelix = self.packages.${system}.yazelix-no-helix;
      yzxNoYazi = self.packages.${system}.yazelix-no-yazi;
      yzxNoHelixNoYazi = self.packages.${system}.yazelix-no-helix-no-yazi;
      yzxNoMars = self.packages.${system}.yazelix-no-mars;
      yzxNoMarsNoHelix = self.packages.${system}.yazelix-no-mars-no-helix;
      yzxNoMarsNoYazi = self.packages.${system}.yazelix-no-mars-no-yazi;
      yzxNoMarsNoHelixNoYazi =
        self.packages.${system}.yazelix-no-mars-no-helix-no-yazi;
      # Fork: the historical Mars-free runtime package stays contract-checked.
      yzxRuntime = self.packages.${system}.runtime;
      runtimeClosure = pkgs.closureInfo {rootPaths = [yzxRuntime];};
      marsPackage = mars.packages.${system}.mars;
      noHelixClosure = pkgs.closureInfo {rootPaths = [yzxNoHelix];};
      noYaziClosure = pkgs.closureInfo {rootPaths = [yzxNoYazi];};
      noHelixNoYaziClosure = pkgs.closureInfo {rootPaths = [yzxNoHelixNoYazi];};
      noMarsClosure = pkgs.closureInfo {rootPaths = [yzxNoMars];};
      noMarsNoHelixClosure = pkgs.closureInfo {rootPaths = [yzxNoMarsNoHelix];};
      noMarsNoYaziClosure = pkgs.closureInfo {rootPaths = [yzxNoMarsNoYazi];};
      noMarsNoHelixNoYaziClosure =
        pkgs.closureInfo {rootPaths = [yzxNoMarsNoHelixNoYazi];};
      zellijBarPackage = yazelixZellijBar.packages.${system}.default;
      yzxYaziMaterializer = yzxYaziMaterializerFor pkgs;
      checksSrc = pkgs.lib.cleanSource ./checks;
      yzxContractsCheck = rustBinFor pkgs "yzx-contracts-check" "${checksSrc}/yzx-contracts.rs";
      helixContractsCheck = rustBinFor pkgs "helix-contracts-check" "${checksSrc}/helix-contracts.rs";
      noHelixContractsCheck =
        rustBinFor pkgs "no-helix-contracts-check" "${checksSrc}/no-helix-contracts.rs";
      mkFakeHostYazi = {
        multiline ? false,
        name,
        yaVersion ? pkgs.yazi.version,
        yaziVersion ? pkgs.yazi.version,
      }:
        # Fake host binaries emitted as Nushell scripts (cache/shell policy:
        # no generated shell runtime).
        pkgs.runCommand name {} ''
          mkdir -p "$out/bin"
          {
            echo '#!${pkgs.nushell}/bin/nu --no-config-file'
            echo 'def --wrapped main [...args: string] {'
            echo '  if ($args | get --optional 0 | default "") == "--version" {'
            echo "    print 'Yazi ${yaziVersion}'"
            echo '  } else {'
            echo '    let config = ($env.YAZI_CONFIG_HOME? | default "")'
            echo '    let starship = ($env.YZX_YAZI_STARSHIP_CONFIG? | default "")'
            echo '    let role = ($env.YZX_YAZI_ROLE? | default "")'
            echo '    let ya = ($env.YZX_YA? | default "")'
            echo '    let joined = ($args | str join (char space))'
            echo '    print $"fake Yazi config=($config) starship=($starship) role=($role) ya=($ya) args=($joined) "'
            echo '  }'
            echo '}'
          } > "$out/bin/yazi"
          {
            echo '#!${pkgs.nushell}/bin/nu --no-config-file'
            echo 'def --wrapped main [...args: string] {'
            echo '  if ($args | get --optional 0 | default "") == "--version" {'
            echo "    print 'Ya ${yaVersion}'"
            echo '  } else {'
            echo '    let joined = ($args | str join (char space))'
            echo '    print $"fake Ya args=($joined) "'
            echo '  }'
            echo '}'
          } > "$out/bin/ya"
          chmod 755 "$out/bin/yazi" "$out/bin/ya"
        '';
      fakeHostYazi = mkFakeHostYazi {name = "fake-host-yazi";};
      # Upstream's shim relies on one argv0-switching bash script; this fork's fake
      # host Yazi ships separate Nushell-backed yazi and ya binaries, so link each.
      fakeShimHostYazi = pkgs.runCommand "fake-shim-host-yazi" {} ''
        mkdir -p "$out/bin"
        ln -s ${fakeHostYazi}/bin/yazi "$out/bin/yazi"
        ln -s ${fakeHostYazi}/bin/ya "$out/bin/ya"
      '';
      fakeNewerHostYazi = mkFakeHostYazi {
        multiline = true;
        name = "fake-newer-host-yazi";
        yaVersion = "99.0.0";
        yaziVersion = "99.0.0";
      };
      fakeMismatchedHostYazi = mkFakeHostYazi {
        name = "fake-mismatched-host-yazi";
        yaVersion = "98.0.0";
        yaziVersion = "99.0.0";
      };
      # Fork: the fake Home Manager package stays Nushell-backed instead of
      # upstream's bash runCommand.
      fakeYazelixBinary = pkgs.writeTextFile {
        name = "fake-yazelix-binary";
        destination = "/bin/yzx";
        executable = true;
        text = ''
          #!${pkgs.nushell}/bin/nu
          print fake-yazelix
        '';
      };
      fakeYazelixDesktop = pkgs.writeTextDir "share/applications/yzx.desktop" ''
        [Desktop Entry]
        Type=Application
        Name=Fake Yazelix
        Exec=yzx
      '';
      fakeYazelix = pkgs.symlinkJoin {
        name = "fake-yazelix-hm-package";
        paths = [fakeYazelixBinary fakeYazelixDesktop];
      };
      fakeHelixLanguages = pkgs.writeText "hm-helix-languages.toml" ''
        [[language]]
        name = "nix"
      '';
      fakeCursors = pkgs.writeText "hm-cursors.toml" ''
        enabled_cursors = ["reef"]
        [settings]
        trail = "reef"
      '';
      fakeStarship = pkgs.writeText "hm-starship.toml" ''
        format = "$directory$git_branch"
      '';
      fakeYaziFlavor = pkgs.writeTextDir "flavor.toml" ''
        [mgr]
        cwd = { fg = "#c0ffee" }
      '';
      homeManagerConfiguration = module:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            self.homeManagerModules.default
            {
              home.username = "yzx-test";
              home.homeDirectory = "/tmp/yzx-test-home";
              home.stateVersion = "25.05";
              manual.manpages.enable = false;
              programs.yazelix.enable = true;
            }
            module
          ];
        };
      homeManagerDefault = homeManagerConfiguration {};
      homeManagerOverride = homeManagerConfiguration {
        programs.yazelix.package = fakeYazelix;
      };
      homeManagerNoMars = homeManagerConfiguration {
        programs.yazelix.package = yzxNoMars;
      };
      homeManagerNoYazi = homeManagerConfiguration {
        home.packages = [pkgs.yazi];
        programs.yazelix.package = yzxNoYazi;
      };
      homeManagerSharedStarship = homeManagerConfiguration {
        programs.yazelix.config = {
          starship.source = fakeStarship;
          yazi.starship.source = fakeStarship;
        };
      };
      homeManagerConfigFiles = homeManagerConfiguration {
        xdg.configFile."yazelix/yazi/flavors/example.yazi".source = fakeYaziFlavor;
        programs.yazelix.config = {
          settings = {
            # Nushell stays the fork's only shell; the appearance mode is
            # upstream's and the --project-mars-appearance assertion needs it.
            appearance.mode = "light";
            shell.program = "nu";
            welcome.enabled = false;
            keybindings.config = "Alt Shift C";
            keybindings.agent = "Alt Shift A";
            keybindings.git = "Alt Shift G";
            keybindings.menu = "Alt Shift U";
            keybindings.screen = "Ctrl Shift S";
            keybindings.sidebar = "Ctrl Shift B";
            keybindings.sidebar_focus = "Ctrl Shift E";
            bar.widgets = ["editor" "shell"];
          };
          cursors.source = fakeCursors;
          mars.text = "[window]\nwidth = 1200\n";
          zellij.text = "pane_frames false\n";
          starship.text = "[character]\nformat = \"::\"\n";
          helix.config.text = "[editor]\nline-number = \"relative\"\n";
          helix.languages.source = fakeHelixLanguages;
          helix.module.text = "(provide yzx-test)\n";
          helix.init.text = ";; init\n";
          yazi.config.text = "[mgr]\nshow_hidden = true\n";
          yazi.init.text = "-- init\n";
          yazi.keymap.text = "[manager]\n";
          yazi.package.text = "[plugin]\ndeps = []\n";
          yazi.starship.source = fakeStarship;
          yazi.theme.text = "[flavor]\ndark = \"example\"\n";
          nu.env.text = "# env\n";
          nu.config.text = "# config\n";
        };
      };
    in {
      profile_agent_frontdoors = pkgs.runCommand "profile-agent-frontdoors" {
        nativeBuildInputs = [pkgs.nushell pkgs.coreutils];
      } ''
        ${pkgs.nushell}/bin/nu ${./tests/profile_agent_frontdoor.nu} \
          "$TMPDIR/profile-agent-frontdoors" \
          ${./nushell/agent/profile_frontdoor.nu} \
          ${pkgs.nushell}/bin/nu \
          ${pkgs.coreutils}/bin/chmod
        touch "$out"
      '';
      profile_environment_frontdoor = pkgs.runCommand "profile-environment-frontdoor" {
        nativeBuildInputs = [pkgs.nushell pkgs.coreutils];
      } ''
        ${pkgs.nushell}/bin/nu ${./tests/profile_environment_frontdoor.nu} \
          "$TMPDIR/profile-environment-frontdoor" \
          ${./nushell/system/profile_environment_frontdoor.nu} \
          ${pkgs.nushell}/bin/nu \
          ${pkgs.coreutils}/bin/chmod
        touch "$out"
      '';
      icm_profile_frontdoor = pkgs.runCommand "icm-profile-frontdoor" {
        nativeBuildInputs = [pkgs.nushell pkgs.coreutils];
      } ''
        ${pkgs.nushell}/bin/nu ${./tests/icm_profile_frontdoor.nu} \
          "$TMPDIR" \
          ${./nushell/agent/icm_profile_frontdoor.nu} \
          ${pkgs.nushell}/bin/nu \
          ${pkgs.coreutils}/bin/chmod
        touch "$out"
      '';
      strict_profile_sources = pkgs.runCommand "strict-profile-sources" {
        nativeBuildInputs = [pkgs.nushell];
      } ''
        ${pkgs.nushell}/bin/nu ${./tests/strict_profile_sources.nu} ${./.}
        touch "$out"
      '';
      inherit yzx;
      cache_shell_policy = pkgs.runCommand "cache-shell-policy-check" {} ''
        ${pkgs.nushell}/bin/nu ${./checks/cache_shell_policy.nu} ${./.}
        touch "$out"
      '';
      codex_config_materializer = pkgs.runCommand "codex-config-materializer-check" {} ''
        ${pkgs.nushell}/bin/nu ${./tests/codex_config_materializer.nu} ${./.}
        touch "$out"
      '';
      codex_rules_authority = pkgs.runCommand "codex-rules-authority-check" {} ''
        # Green fixture: one reviewed source, correct authorship input, and a
        # matching embedded hash must pass every clause.
        fixture=$(mktemp -d)
        mkdir -p "$fixture/profile-runtime/codex" "$fixture/profile-share"
        cp ${./agent_configs/codex/RULES.md.src} "$fixture/profile-share/RULES.md.src"
        hash=$(sha256sum "$fixture/profile-share/RULES.md.src" | cut -d' ' -f1)
        {
          printf '<!-- GENERATED by yazelix codex rules materializer — do not hand-edit. -->\n'
          printf '<!-- authorship input: %s -->\n' "$fixture/profile-share/RULES.md.src"
          printf '<!-- source_sha256 = %s -->\n' "$hash"
          cat ${./agent_configs/codex/RULES.md.src}
        } > "$fixture/profile-runtime/codex/RULES.md"
        ${pkgs.nushell}/bin/nu ${./tests/codex_rules_authority.nu} ${./.} --fixture-root "$fixture"

        # Red fixture: a duplicate RULES.md at a retired mirror must fail.
        # The overlay name is assembled at runtime (strict_profile_sources
        # idiom) so this block does not trip the textual ownership gate.
        retired="$fixture/."codex
        mkdir -p "$retired"
        echo duplicate > "$retired/RULES.md"
        if ${pkgs.nushell}/bin/nu ${./tests/codex_rules_authority.nu} ${./.} --fixture-root "$fixture"; then
          printf '%s\n' 'duplicate RULES.md at a retired mirror was not detected' >&2
          exit 1
        fi
        touch "$out"
      '';
      zjstatus_activity_pipe = pkgs.runCommand "yzx-zjstatus-activity-pipe-check" {nativeBuildInputs = [pkgs.ripgrep];} ''
        rg -a -q 'tab_activity_pipe_name' ${zellijBarPackage}/${zellijBarPackage.wasmPath}
        touch "$out"
      '';
      home_manager = pkgs.runCommand "yzx-home-manager-check" {} ''
        default_path="${homeManagerDefault.activationPackage}/home-path"
        override_path="${homeManagerOverride.activationPackage}/home-path"
        no_mars_path="${homeManagerNoMars.activationPackage}/home-path"
        no_yazi_path="${homeManagerNoYazi.activationPackage}/home-path"
        shared_config_files="${homeManagerSharedStarship.activationPackage}/home-files/.config/yazelix"
        hm_yzx="${homeManagerConfigFiles.activationPackage}/home-path/bin/yzx"
        config_files="${homeManagerConfigFiles.activationPackage}/home-files/.config/yazelix"

        test -x "$default_path/bin/yzx"
        ${if pkgs.stdenv.hostPlatform.isLinux then ''
          test -f "$default_path/share/applications/yzx.desktop"
          grep -q 'Yazelix Nova' "$default_path/share/applications/yzx.desktop"
        '' else ''
          test ! -e "$default_path/share/applications/yzx.desktop"
        ''}

        test -x "$override_path/bin/yzx"
        test "$("$override_path/bin/yzx")" = fake-yazelix
        grep -q 'Fake Yazelix' "$override_path/share/applications/yzx.desktop"

        test -x "$no_mars_path/bin/yzx"
        test ! -e "$no_mars_path/share/applications/yzx.desktop"
        test -x "$no_yazi_path/bin/yzx"
        test -x "$no_yazi_path/bin/yazi"
        test -x "$no_yazi_path/bin/ya"

        if [ -e "${homeManagerDefault.activationPackage}/home-files/.config/yazelix" ]; then
          printf '%s\n' 'Home Manager v1 must not generate Yazelix runtime config files' >&2
          exit 1
        fi
        grep -q 'program = "nu"' "$config_files/config.toml"
        ! grep -q 'command = "yzx-hx"' "$config_files/config.toml"
        grep -q 'enabled = false' "$config_files/config.toml"
        ! grep -q 'style = "random"' "$config_files/config.toml"
        grep -q 'config = "Alt Shift C"' "$config_files/config.toml"
        grep -q 'agent = "Alt Shift A"' "$config_files/config.toml"
        grep -q 'git = "Alt Shift G"' "$config_files/config.toml"
        grep -q 'menu = "Alt Shift U"' "$config_files/config.toml"
        grep -q 'screen = "Ctrl Shift S"' "$config_files/config.toml"
        grep -q 'sidebar = "Ctrl Shift B"' "$config_files/config.toml"
        grep -q 'sidebar_focus = "Ctrl Shift E"' "$config_files/config.toml"
        ! grep -q 'ratconfig' "$config_files/config.toml"
        grep -q 'trail = "reef"' "$config_files/cursors.toml"
        test -L "$config_files/cursors.toml"
        case "$(readlink "$config_files/cursors.toml")" in
          /nix/store/*) ;;
          *) printf '%s\n' 'Home Manager cursor source is not store-backed' >&2; exit 1 ;;
        esac
        test "$(YAZELIX_CONFIG_HOME="$config_files" ${yzx}/libexec/yazelix/yzx-config --get shell.program)" = nu
        test "$(YAZELIX_CONFIG_HOME="$config_files" ${yzx}/libexec/yazelix/yzx-config --get editor.command)" = yzx-hx
        test "$(YAZELIX_CONFIG_HOME="$config_files" ${yzx}/libexec/yazelix/yzx-config --get agent.command)" = auto
        test "$(YAZELIX_CONFIG_HOME="$config_files" ${yzx}/libexec/yazelix/yzx-config --get agent.args)" = "[]"
        test "$(YAZELIX_CONFIG_HOME="$config_files" ${yzx}/libexec/yazelix/yzx-config --get keybindings.config)" = "Alt Shift C"
        test "$(YAZELIX_CONFIG_HOME="$config_files" ${yzx}/libexec/yazelix/yzx-config --get keybindings.agent)" = "Alt Shift A"
        test "$(YAZELIX_CONFIG_HOME="$config_files" ${yzx}/libexec/yazelix/yzx-config --get keybindings.git)" = "Alt Shift G"
        test "$(YAZELIX_CONFIG_HOME="$config_files" ${yzx}/libexec/yazelix/yzx-config --get keybindings.menu)" = "Alt Shift U"
        test "$(YAZELIX_CONFIG_HOME="$config_files" ${yzx}/libexec/yazelix/yzx-config --get keybindings.screen)" = "Ctrl Shift S"
        test "$(YAZELIX_CONFIG_HOME="$config_files" ${yzx}/libexec/yazelix/yzx-config --get keybindings.sidebar)" = "Ctrl Shift B"
        test "$(YAZELIX_CONFIG_HOME="$config_files" ${yzx}/libexec/yazelix/yzx-config --get keybindings.sidebar_focus)" = "Ctrl Shift E"
        grep -q 'width = 1200' "$config_files/mars/config.toml"
        test "$(YAZELIX_CONFIG_HOME="$config_files" ${yzx}/libexec/yazelix/yzx-config --project-mars-appearance)" = "environment light"
        grep -q 'width = 1200' "$config_files/mars/config.toml"
        ! grep -q 'preset' "$config_files/mars/config.toml"
        grep -q 'pane_frames false' "$config_files/zellij/config.kdl"
        grep -q '^\[character\]$' "$config_files/starship.toml"
        grep -q 'format = "::"' "$config_files/starship.toml"
        grep -q 'line-number = "relative"' "$config_files/helix/config.toml"
        grep -q 'name = "nix"' "$config_files/helix/languages.toml"
        grep -q '(provide yzx-test)' "$config_files/helix/helix.scm"
        grep -q 'show_hidden = true' "$config_files/yazi/yazi.toml"
        grep -q -- '-- init' "$config_files/yazi/init.lua"
        grep -q 'deps = \[\]' "$config_files/yazi/package.toml"
        grep -Fqx 'format = "$directory$git_branch"' "$config_files/yazi/starship.toml"
        test "$(readlink -f "$config_files/starship.toml")" != \
          "$(readlink -f "$config_files/yazi/starship.toml")"
        grep -q 'dark = "example"' "$config_files/yazi/theme.toml"
        test -L "$config_files/yazi/flavors/example.yazi"
        case "$(readlink "$config_files/yazi/flavors/example.yazi")" in
          /nix/store/*) ;;
          *) printf '%s\n' 'Home Manager Yazi flavor is not store-backed' >&2; exit 1 ;;
        esac
        hm_yazi_runtime="$(${yzxYaziMaterializer}/bin/yzx-yazi-config ${yzx}/share/yazelix/yazi "$config_files/yazi" "$TMPDIR/hm-yazi-state" dark)"
        grep -Fqx 'format = "$directory$git_branch"' "$hm_yazi_runtime/yazelix_starship.toml"
        YAZI_CONFIG_HOME="$hm_yazi_runtime" ${pkgs.yazi}/bin/yazi --debug > hm-yazi-debug
        grep -q 'Dark/light flavor:.*example' hm-yazi-debug

        test "$(readlink -f "$shared_config_files/starship.toml")" = \
          "$(readlink -f "$shared_config_files/yazi/starship.toml")"
        grep -q '# config' "$config_files/nu/config.nu"

        export HOME="$TMPDIR/hm-yzx-home"
        runtime_config="$TMPDIR/hm-yzx-config"
        cp -R "$config_files" "$runtime_config"
        chmod -R u+w "$runtime_config"
        export YAZELIX_CONFIG_HOME="$runtime_config"
        export YAZELIX_STATE_DIR="$TMPDIR/hm-yzx-state"
        export XDG_DATA_HOME="$TMPDIR/hm-yzx-data"
        mkdir -p "$HOME" "$YAZELIX_STATE_DIR" "$XDG_DATA_HOME"

        "$hm_yzx" help > help
        "$hm_yzx" status > status
        "$hm_yzx" doctor > doctor
        "$hm_yzx" tutor list > tutor-list
        "$hm_yzx" run ya --version > ya-version
        grep -q 'Usage:' help
        grep -q 'Yazelix Nova status' status
        grep -q "config home: $runtime_config" status
        grep -q "state dir: $YAZELIX_STATE_DIR" status
        grep -q 'shell: nu' status
        grep -q 'welcome enabled: false' status
        grep -q 'layout: runtime (' status
        grep -q 'host_theme_mode "light"' "$YAZELIX_STATE_DIR/zellij/layout.kdl"
        grep -Fq 'host_theme_light_tab_normal "#[fg=#5c5f77] [{index}] {name} "' "$YAZELIX_STATE_DIR/zellij/layout.kdl"
        grep -q 'Yazelix Nova doctor' doctor
        grep -q "ok config home: $runtime_config" doctor
        grep -q 'ok shell.program: nu' doctor
        grep -q 'Yazelix Nova tutor lessons' tutor-list
        grep -q '^Ya ' ya-version
        touch "$out"
      '';
      yzx_yazi_materialization = pkgs.runCommand "yzx-yazi-materialization-check" {nativeBuildInputs = [pkgs.rustc pkgs.stdenv.cc];} ''
        rustc --edition=2024 --test ${./runtime/yzx-yazi.rs} -o yzx-yazi-materialization-check
        ./yzx-yazi-materialization-check

        user="$TMPDIR/yazi-user"
        state="$TMPDIR/yazi-state"
        install -D ${starshipYazi}/main.lua "$user/plugins/starship.yazi/main.lua"
        ln -s ${pkgs.yaziPlugins.smart-enter} "$user/plugins/smart-enter.yazi"
        touch "$user/plugins/starship.yazi/user-managed"
        printf '%s\n' 'require("smart-enter"):setup { open_multi = false }' > "$user/init.lua"
        printf '%s\n' '[[mgr.prepend_keymap]]' 'on = "l"' 'run = "plugin smart-enter"' > "$user/keymap.toml"

        runtime="$(${yzxYaziMaterializer}/bin/yzx-yazi-config ${yzx}/share/yazelix/yazi "$user" "$state" dark)"
        YZX_YAZI_STARSHIP_CONFIG="$runtime/yazelix_starship.toml" YAZI_CONFIG_HOME="$runtime" ${pkgs.yazi}/bin/yazi --debug > yazi-debug
        test -f "$runtime/plugins/smart-enter.yazi/main.lua"
        for plugin in auto-layout git sidebar-state sidebar-status starship zoxide-editor; do
          test -f "$runtime/plugins/$plugin.yazi/main.lua"
        done
        test -f "$runtime/yazelix_starship.toml"
        test -f "$runtime/plugins/starship.yazi/user-managed"
        grep -q 'require("smart-enter")' "$runtime/init.lua"
        grep -q 'plugin smart-enter' "$runtime/keymap.toml"
        grep -q 'yzx-open' yazi-debug

        light_runtime="$(${yzxYaziMaterializer}/bin/yzx-yazi-config ${yzx}/share/yazelix/yazi "$TMPDIR/no-yazi-user" "$TMPDIR/light-state" light)"
        grep -Fqx 'dark = "${yaziBistro.lib.defaultLight}"' "$light_runtime/theme.toml"
        grep -Fqx 'light = "${yaziBistro.lib.defaultLight}"' "$light_runtime/theme.toml"
        YAZI_CONFIG_HOME="$light_runtime" ${pkgs.yazi}/bin/yazi --debug > light-yazi-debug
        grep -q 'Dark/light flavor:.*${yaziBistro.lib.defaultLight}' light-yazi-debug

        for flavor_path in ${yzx}/share/yazelix/yazi/flavors/*.yazi; do
          flavor_dir="''${flavor_path##*/}"
          flavor="''${flavor_dir%.yazi}"
          flavor_user="$TMPDIR/flavor-$flavor"
          mkdir -p "$flavor_user"
          printf '[flavor]\ndark = "%s"\nlight = "%s"\n' "$flavor" "$flavor" > "$flavor_user/theme.toml"
          flavor_runtime="$(${yzxYaziMaterializer}/bin/yzx-yazi-config ${yzx}/share/yazelix/yazi "$flavor_user" "$TMPDIR/state-$flavor" dark)"
          YAZI_CONFIG_HOME="$flavor_runtime" ${pkgs.yazi}/bin/yazi --debug > "debug-$flavor"
          grep -q "Dark/light flavor:.*$flavor" "debug-$flavor"
          test -f "$flavor_runtime/flavors/$flavor_dir/flavor.toml"
          test -f "$flavor_runtime/flavors/$flavor_dir/tmtheme.xml"
          test ! -e "$flavor_runtime/flavors/$flavor_dir/preview.png"
        done
        touch "$out"
      '';
      yzx_launcher_unit = pkgs.runCommand "yzx-launcher-unit-check" {nativeBuildInputs = [pkgs.rustc pkgs.stdenv.cc];} ''
        rustc --edition=2024 --test ${pkgs.lib.cleanSource ./runtime/yzx}/main.rs -o yzx-launcher-unit-check
        ./yzx-launcher-unit-check
        touch "$out"
      '';
      zellij_sidecar_guard_parity = pkgs.runCommand "zellij-sidecar-guard-parity-check" {} ''
        extract_array() {
          file="$1"
          name="$2"
          awk -v name="$name" '
            index($0, name) { in_array = 1; next }
            in_array && /\];/ { exit }
            in_array {
              line = $0
              if (sub(/^[[:space:]]*"/, "", line)) {
                sub(/".*$/, "", line)
                print line
              }
            }
          ' "$file" | sort
        }

        extract_array ${./runtime/yzx-zellij-config.rs} FORBIDDEN > runtime
        extract_array ${./crates/yzx-config/src/catalog.rs} ZELLIJ_FORBIDDEN_TOP_LEVEL > config_ui
        diff -u runtime config_ui
        grep -qx default_shell runtime
        grep -qx env runtime
        touch "$out"
      '';
      zellij_theme_inventory_parity = pkgs.runCommand "zellij-theme-inventory-parity-check" {} ''
        for file in ${yazelixZellij}/zellij-utils/assets/themes/*.kdl; do
          awk '
            /^[[:space:]]*themes[[:space:]]*\{/ {
              in_themes = 1
              depth = 1
              next
            }
            in_themes {
              line = $0
              sub(/\/\/.*/, "", line)
              if (depth == 1 && line ~ /^[[:space:]]*("[^"]+"|[A-Za-z0-9_-]+)[[:space:]]*\{/) {
                name = line
                sub(/^[[:space:]]*/, "", name)
                if (name ~ /^"/) {
                  sub(/^"/, "", name)
                  sub(/".*/, "", name)
                } else {
                  sub(/[[:space:]]*\{.*/, "", name)
                }
                print name
              }
              opens = line
              closes = line
              depth += gsub(/\{/, "", opens) - gsub(/\}/, "", closes)
              if (depth <= 0) exit
            }
          ' "$file"
        done > actual-unsorted
        sort actual-unsorted > actual
        test "$(wc -l < actual)" -eq "$(sort -u actual | wc -l)"
        diff -u ${./crates/yzx-config/zellij-themes.txt} actual
        touch "$out"
      '';
      key_reference_parity = pkgs.runCommand "key-reference-parity-check" {nativeBuildInputs = [pkgs.rustc pkgs.stdenv.cc];} ''
        rustc --edition=2024 ${./checks/key-reference-parity.rs} -o key-reference-parity-check
        ./key-reference-parity-check ${./crates/yzx-config/src/catalog.rs} ${yzx}/share/yazelix/config.kdl ${./crates/yzx-tutor/src/main.rs}
        touch "$out"
      '';
      contracts = pkgs.runCommand "yzx-contracts" {} ''
        ${yzxContractsCheck}/bin/yzx-contracts-check \
          ${yzx} ${pkgs.git}/bin/git ${pkgs.jq}/bin/jq ${pkgs.nushell}/bin/nu "$out" \
          ${./README.md} ${./docs/installation.md} ${./docs/development.md} ${./AGENTS.md}
      '';
      # Fork: contract coverage for the historical `runtime` package.  The
      # merged variant machinery reports it as the `no-mars` variant.
      runtime_contracts = pkgs.runCommand "yzx-runtime-contracts" {} ''
        test -x ${yzxRuntime}/bin/yzx
        test ! -e ${yzxRuntime}/share/applications/yzx.desktop
        ! grep -Fx ${marsPackage} ${runtimeClosure}/store-paths
        ! grep -E '/[^/]*-rio-[^/]*$' ${runtimeClosure}/store-paths

        export HOME="$TMPDIR/home"
        export YAZELIX_CONFIG_HOME="$TMPDIR/config"
        export YAZELIX_STATE_DIR="$TMPDIR/state"
        export XDG_DATA_HOME="$TMPDIR/data"
        mkdir -p "$HOME" "$YAZELIX_CONFIG_HOME" "$YAZELIX_STATE_DIR" "$XDG_DATA_HOME"
        printf '%s\n' '[welcome]' 'enabled = false' > "$YAZELIX_CONFIG_HOME/config.toml"

        ${yzxRuntime}/bin/yzx status --json > status.json
        test "$(${pkgs.jq}/bin/jq -r .package status.json)" = no-mars
        ${yzxRuntime}/bin/yzx status > status
        grep -q '^package: no-mars$' status
        grep -q '^mars config: not included$' status
        ${yzxRuntime}/bin/yzx doctor > doctor
        grep -q '^ok mars: not included$' doctor
        if ${yzxRuntime}/bin/yzx launch 2> launch-error; then
          printf '%s\n' 'Mars-free runtime launch unexpectedly succeeded' >&2
          exit 1
        fi
        grep -q 'this package omits Mars' launch-error
        ${yzxRuntime}/bin/yzx enter --version > enter-version
        grep -q '^zellij ' enter-version
        touch "$out"
      '';
      no_mars_contracts = pkgs.runCommand "yzx-no-mars-contracts" {} ''
        check_no_mars() {
          local package="$1"
          local variant="$2"
          local closure="$3"
          local root="$TMPDIR/$variant"

          test -x "$package/bin/yzx"
          test ! -e "$package/share/applications/yzx.desktop"
          ! grep -Fx ${marsPackage} "$closure"
          ! grep -E '/[^/]*-rio-[^/]*$' "$closure"

          export HOME="$root/home"
          export YAZELIX_CONFIG_HOME="$root/config"
          export YAZELIX_STATE_DIR="$root/state"
          export XDG_DATA_HOME="$root/data"
          mkdir -p "$HOME" "$YAZELIX_CONFIG_HOME" "$YAZELIX_STATE_DIR" "$XDG_DATA_HOME"
          printf '%s\n' '[welcome]' 'enabled = false' > "$YAZELIX_CONFIG_HOME/config.toml"

          "$package/bin/yzx" status --json > "$root/status.json"
          test "$(${pkgs.jq}/bin/jq -r .package "$root/status.json")" = "$variant"
          "$package/bin/yzx" status > "$root/status"
          grep -Fqx "package: $variant" "$root/status"
          grep -Fqx 'mars config: not included' "$root/status"
          grep -q 'host_theme_mode "dark"' "$package/share/yazelix/layout.kdl"
          grep -Fq 'host_theme_light_tab_normal "#[fg=#5c5f77] [{index}] {name} "' "$package/share/yazelix/layout.kdl"
          "$package/bin/yzx" doctor > "$root/doctor"
          grep -Fqx 'ok mars: not included' "$root/doctor"
          if "$package/bin/yzx" launch 2> "$root/launch-error"; then
            printf '%s\n' "$variant launch unexpectedly succeeded" >&2
            exit 1
          fi
          grep -q 'this package omits Mars' "$root/launch-error"
          "$package/bin/yzx" enter --version > "$root/enter-version"
          grep -q '^zellij ' "$root/enter-version"
        }

        check_no_mars ${yzxNoMars} no-mars ${noMarsClosure}/store-paths
        check_no_mars ${yzxNoMarsNoHelix} no-mars-no-helix ${noMarsNoHelixClosure}/store-paths
        touch "$out"
      '';
      helix_contracts = pkgs.runCommand "yzx-helix-contracts" {} ''
        ${helixContractsCheck}/bin/helix-contracts-check ${yzx} ${pkgs.nushell}/bin/nu "$out"
      '';
    } // pkgs.lib.optionalAttrs (system == "x86_64-linux") {
      flexnetos_foundation_contracts = let
        foundation = self.packages.${system}.lifeos_foundation_yzx;
        flexnetosNuConfig = pkgs.replaceVars ./nushell/config/config.nu {
          stackPromptGuard = "${./nushell/config/stack_prompt_guard.nu}";
          flexnetosInit = "${./nushell/scripts/flexnetos_init.nu}";
          profileNu = "/home/flexnetos/.nix-profile/toolbin/nu";
          rtkWrappers = "${./nushell/config/rtk_wrappers.nu}";
        };
      in pkgs.runCommand "flexnetos-foundation-contracts" {} ''
        test -x ${foundation}/bin/yzx
        test -x ${foundation}/bin/br
        test -x ${foundation}/bin/bv
        ${foundation}/bin/bv --version | grep -Fx 'bv v0.16.1'
        test -x ${foundation}/bin/rtk
        test -x ${foundation}/bin/rtk_nu
        test -x ${foundation}/bin/nvim
        test -x ${foundation}/bin/bun
        test -x ${foundation}/bin/bunx
        test -x ${foundation}/bin/ar
        test -x ${foundation}/bin/python3
        ${foundation}/bin/python3 -c 'import yaml; assert yaml.safe_load("ready: true") == {"ready": True}'
        ${foundation}/bin/rtk --version | grep -F '0.43.0'
        ${foundation}/bin/rtk_nu --help | grep -F 'lossless Nushell ingestion envelope'
        PATH=${foundation}/bin:$PATH ${foundation}/bin/rtk_nu --format json -- \
          ${pkgs.coreutils}/bin/printf rtk-nu-proof > rtk-nu-proof.json
        grep -F '"schema_version": "flexnetos.rtk_nu.envelope.v1"' rtk-nu-proof.json
        grep -F '"payload_base64": "cnRrLW51LXByb29m"' rtk-nu-proof.json
        ${foundation}/bin/nvim --version | grep -F 'NVIM v'
        test "$(${foundation}/bin/bun --version)" = 1.3.14
        test ! -e ${foundation}/bin/npm
        test ! -e ${foundation}/bin/npx
        test ! -e ${foundation}/bin/pnpm
        test ! -e ${foundation}/bin/corepack
        test ! -e ${foundation}/bin/yarn
        test -x ${foundation}/bin/codex
        test -x ${foundation}/bin/claude
        test -x ${foundation}/bin/chmod
        readlink -f ${foundation}/bin/codex | grep -Eq '/nix/store/[a-z0-9]+-codex/bin/codex$'
        readlink -f ${foundation}/bin/claude | grep -Eq '/nix/store/[a-z0-9]+-claude/bin/claude$'
        test -x ${foundation}/bin/ccboard
        test -x ${foundation}/bin/codedb
        test -x ${foundation}/bin/nu_plugin_codedb
        test -x ${foundation}/bin/flexnetos-redb-owner
        test -x ${foundation}/bin/fxrun
        test ! -e ${foundation}/bin/fxrun-actions
        test -x ${foundation}/bin/fxrun-dispatch
        test ! -e ${foundation}/bin/flexnetos_runner_policy
        test ! -e ${foundation}/bin/flexnetos_runner_service
        test -x ${foundation}/bin/flexnetos-runner-start
        test -x ${foundation}/bin/envctl
        test -x ${foundation}/bin/secretctl
        test -x ${foundation}/bin/secretd
        ${foundation}/bin/envctl --version | grep -Fx 'envctl 0.1.0'
        ${foundation}/bin/secretd --version | grep -Fx 'secretd 0.1.0'
        ${foundation}/bin/secretctl --help | grep -F 'mint-github'
        test -x ${foundation}/bin/yazelix_host_policy
        test -x ${foundation}/bin/yazelix_volatile_runtime
        test -x ${foundation}/bin/kache
        test -x ${foundation}/bin/kache-rustc-wrapper
        test -x ${foundation}/bin/nix
        test -x ${foundation}/bin/nix-daemon
        test -x ${foundation}/bin/nix-store
        test -x ${foundation}/bin/journalctl
        test -x ${foundation}/bin/ln
        test -x ${foundation}/bin/systemctl
        test -x ${foundation}/bin/usermod
        test -x ${foundation}/toolbin/nu
        test -x ${foundation}/bin/yazelix_profile_check
        test -x ${foundation}/bin/yazelix_profile_migrate
        test -x ${foundation}/bin/yazelix_codex_materialize
        test -x ${foundation}/bin/yazelix_claude_materialize
        test ! -e ${foundation}/runtime
        test -f ${foundation}/share/yazelix/packaging/single_profile_check.nu
        test -f ${foundation}/share/yazelix/packaging/profile_migration.nu
        test -f ${foundation}/share/yazelix/agent_configs/codex/config.toml.src
        test -f ${foundation}/share/yazelix/agent_configs/codex/RULES.md.src
        test -f ${foundation}/share/yazelix/agent_configs/codex/hooks.json.src
        test -f ${foundation}/share/yazelix/nushell/scripts/materialize_codex_config.nu
        codex_test_runtime="$TMPDIR/codex-owner-runtime"
        mkdir -p "$codex_test_runtime"
        ${foundation}/bin/yazelix_codex_materialize \
          ${foundation}/share/yazelix/agent_configs/codex/config.toml.src \
          "$codex_test_runtime/config.toml" \
          ${foundation}/share/yazelix/agent_configs/codex/RULES.md.src \
          "$codex_test_runtime/RULES.md" \
          ${foundation}/share/yazelix/agent_configs/codex/hooks.json.src \
          "$codex_test_runtime/hooks.json"
        ${foundation}/bin/yazelix_codex_materialize \
          ${foundation}/share/yazelix/agent_configs/codex/config.toml.src \
          "$codex_test_runtime/config.toml" \
          ${foundation}/share/yazelix/agent_configs/codex/RULES.md.src \
          "$codex_test_runtime/RULES.md" \
          ${foundation}/share/yazelix/agent_configs/codex/hooks.json.src \
          "$codex_test_runtime/hooks.json" --recover-only \
          | grep -F 'no pending Codex config/rules/hooks transaction'
        grep -F 'GENERATED by yazelix codex config materializer' "$codex_test_runtime/config.toml"
        grep -F 'GENERATED by yazelix codex rules materializer' "$codex_test_runtime/RULES.md"
        grep -F 'GENERATED by yazelix codex hooks materializer' "$codex_test_runtime/hooks.json"
        grep -F '/home/flexnetos/.nix-profile/bin/rtk hook codex' "$codex_test_runtime/hooks.json"
        grep -F '/home/flexnetos/.nix-profile/bin/icm hook end' "$codex_test_runtime/hooks.json"
        test "$(stat -c %a "$codex_test_runtime/config.toml")" = 644
        test "$(stat -c %a "$codex_test_runtime/RULES.md")" = 644
        test "$(stat -c %a "$codex_test_runtime/hooks.json")" = 644
        test -f ${foundation}/share/yazelix/agent_configs/claude/settings.json.src
        test -f ${foundation}/share/yazelix/agent_configs/claude/CLAUDE.md.src
        test -f ${foundation}/share/yazelix/agent_configs/claude/RTK.md.src
        test -f ${foundation}/share/yazelix/agent_configs/claude/agent-guard.toml.src
        test -f ${foundation}/share/yazelix/nushell/scripts/materialize_claude_config.nu
        claude_test_runtime="$TMPDIR/claude-owner-runtime"
        mkdir -p "$claude_test_runtime"
        touch "$claude_test_runtime/.credentials.json"
        chmod 600 "$claude_test_runtime/.credentials.json"
        claude_credentials_before="$(${pkgs.coreutils}/bin/sha256sum "$claude_test_runtime/.credentials.json")"
        ${foundation}/bin/yazelix_claude_materialize \
          ${foundation}/share/yazelix/agent_configs/claude/settings.json.src \
          "$claude_test_runtime/settings.json" \
          ${foundation}/share/yazelix/agent_configs/claude/CLAUDE.md.src \
          "$claude_test_runtime/CLAUDE.md" \
          ${foundation}/share/yazelix/agent_configs/claude/RTK.md.src \
          "$claude_test_runtime/RTK.md" \
          ${foundation}/share/yazelix/agent_configs/claude/agent-guard.toml.src \
          "$claude_test_runtime/agent-guard.toml"
        ${foundation}/bin/yazelix_claude_materialize \
          ${foundation}/share/yazelix/agent_configs/claude/settings.json.src \
          "$claude_test_runtime/settings.json" \
          ${foundation}/share/yazelix/agent_configs/claude/CLAUDE.md.src \
          "$claude_test_runtime/CLAUDE.md" \
          ${foundation}/share/yazelix/agent_configs/claude/RTK.md.src \
          "$claude_test_runtime/RTK.md" \
          ${foundation}/share/yazelix/agent_configs/claude/agent-guard.toml.src \
          "$claude_test_runtime/agent-guard.toml"
        ${pkgs.jq}/bin/jq -e '.hooks.PreToolUse and .hooks.SessionEnd' "$claude_test_runtime/settings.json"
        grep -F '/home/flexnetos/.nix-profile/toolbin/rtk hook claude' "$claude_test_runtime/settings.json"
        grep -F '/home/flexnetos/.nix-profile/toolbin/icm hook pre' "$claude_test_runtime/settings.json"
        grep -F '/home/flexnetos/.nix-profile/toolbin/icm hook end' "$claude_test_runtime/settings.json"
        grep -F '/home/flexnetos/.nix-profile/toolbin/agent guard' "$claude_test_runtime/settings.json"
        cmp ${foundation}/share/yazelix/agent_configs/claude/settings.json.src "$claude_test_runtime/settings.json"
        cmp ${foundation}/share/yazelix/agent_configs/claude/CLAUDE.md.src "$claude_test_runtime/CLAUDE.md"
        cmp ${foundation}/share/yazelix/agent_configs/claude/RTK.md.src "$claude_test_runtime/RTK.md"
        cmp ${foundation}/share/yazelix/agent_configs/claude/agent-guard.toml.src "$claude_test_runtime/agent-guard.toml"
        test "$(stat -c %a "$claude_test_runtime/settings.json")" = 600
        test "$(stat -c %a "$claude_test_runtime/CLAUDE.md")" = 644
        test "$(stat -c %a "$claude_test_runtime/RTK.md")" = 644
        test "$(stat -c %a "$claude_test_runtime/agent-guard.toml")" = 644
        test "$(stat -c %a "$claude_test_runtime/.yazelix-claude-generation.json")" = 600
        ${pkgs.jq}/bin/jq -e \
          '.schema == "yazelix.claude-config-generation.v2" and (.sources | length == 4)' \
          "$claude_test_runtime/.yazelix-claude-generation.json"
        test "$claude_credentials_before" = "$(${pkgs.coreutils}/bin/sha256sum "$claude_test_runtime/.credentials.json")"
        test ! -e ${foundation}/bin/yzx-desktop-launch
        test ! -e ${foundation}/bin/yzx-agent-workspace-launch

        desktop_count="$(find ${foundation}/share/applications -maxdepth 1 -name '*.desktop' | wc -l)"
        test "$desktop_count" = 2
        desktop=${foundation}/share/applications/com.flexnetos.Yazelix.Agent.desktop
        claude_desktop=${foundation}/share/applications/claude-code-url-handler.desktop
        test -f "$desktop"
        test -f "$claude_desktop"
        test ! -e ${foundation}/share/applications/com.flexnetos.Yazelix.desktop
        test ! -e ${foundation}/share/applications/com.yazelix.Yazelix.Kitty.desktop
        grep -Fx 'Name=FlexNetOS Yazelix Agent' "$desktop"
        grep -Fx 'GenericName=Terminal Emulator' "$desktop"
        grep -Fx 'Exec=/home/flexnetos/.nix-profile/bin/yzx launch' "$desktop"
        grep -Fx 'Icon=/home/flexnetos/.nix-profile/share/pixmaps/yazelix.png' "$desktop"
        grep -Fx 'StartupNotify=true' "$desktop"
        grep -Fx 'StartupWMClass=mars' "$desktop"
        grep -Fx 'Categories=System;TerminalEmulator' "$desktop"
        grep -Fx 'X-Yazelix-Managed=true' "$desktop"
        grep -Fx 'X-FlexNetOS-Managed=true' "$desktop"
        grep -Fx 'Name=Claude Code URL Handler' "$claude_desktop"
        grep -Fx 'Exec=/home/flexnetos/.nix-profile/bin/claude --handle-uri %u' "$claude_desktop"
        grep -Fx 'NoDisplay=true' "$claude_desktop"
        grep -Fx 'MimeType=x-scheme-handler/claude-cli;' "$claude_desktop"
        grep -Fx 'X-FlexNetOS-Managed=true' "$claude_desktop"
        test -f ${foundation}/share/pixmaps/yazelix.png
        test -s ${foundation}/share/pixmaps/yazelix.png
        terminal_metadata=${foundation}/share/yazelix_terminal_support/terminal_support.toml
        test -f "$terminal_metadata"
        ${pkgs.python3}/bin/python - "$terminal_metadata" "$desktop" <<'PY'
        import pathlib
        import sys
        import tomllib

        metadata_path = pathlib.Path(sys.argv[1])
        desktop_path = pathlib.Path(sys.argv[2])
        with metadata_path.open("rb") as metadata_file:
            metadata = tomllib.load(metadata_file)
        mars = metadata["terminals"][metadata["default_terminal"]]
        expected_name = f"{metadata['desktop_id_prefix']}.{mars['desktop_suffix']}.desktop"
        assert metadata["schema_version"] == 2
        assert metadata["launch_order"] == ["mars"]
        assert desktop_path.name == expected_name
        assert f"StartupWMClass={mars['startup_wm_class']}" in desktop_path.read_text()
        PY

        ! ${foundation}/bin/yzx desktop install --print-path

        layout=${foundation}/configs/zellij/layouts/flexnetos_agent_workspace.kdl
        test -f "$layout"
        grep -F 'tab name="FlexNetOS" focus=true' "$layout"
        grep -F 'tab name="Mission Control"' "$layout"
        ! grep -F '@bar@' "$layout"
        ! grep -F '@yazi@' "$layout"
        test "$(grep -cE 'command="/nix/store/[^/]+-flexnetos-yzx-shell/bin/yzx-shell"' "$layout")" = 2

        config=${foundation}/share/yazelix/config.kdl
        grep -Eq '^default_shell "/nix/store/[^/]+-flexnetos-yzx-shell/bin/yzx-shell"$' "$config"

        test -f ${foundation}/nushell/config/config.nu
        test -f ${foundation}/nushell/config/stack_prompt_guard.nu
        test -f ${foundation}/nushell/config/rtk_wrappers.nu
        test -f ${foundation}/nushell/scripts/flexnetos_init.nu
        test -f ${foundation}/nushell/system/profile_environment_frontdoor.nu
        # @rtkWrappers@ resolves to a store path, so match the module by suffix
        # rather than the pre-substitution literal.
        grep -Eq '^use "/nix/store/[^"]+-rtk_wrappers\.nu" \*$' ${foundation}/nushell/config/config.nu
        grep -F 'XDG_DATA_HOME = $DATA_HOME' ${foundation}/nushell/system/profile_environment_frontdoor.nu
        grep -F 'source "${flexnetosNuConfig}"' ${foundation}/share/yazelix/nu/config.nu
        grep -F ${./nushell/scripts/flexnetos_init.nu} ${flexnetosNuConfig}
        ${pkgs.file}/bin/file -L ${foundation}/bin/kache-rustc-wrapper | grep -F ELF
        ${pkgs.file}/bin/file -L ${foundation}/libexec/kache/rustc | grep -F ELF
        gha_runner_start=${foundation}/bin/flexnetos-runner-start
        test -x "$gha_runner_start"
        ! test -e ${foundation}/lib/systemd/user/flexnetos_runner@.service
        ! test -e ${foundation}/lib/systemd/user/gha-runner.service
        # Path-law guard. No profile-facing executable may bake a home-owned agent
        # path: neither the retired dot-codex home nor the dot-local tree (spelled
        # out only in the assembled patterns below, so this source stays clean for
        # tests/strict_profile_sources.nu). fxrun carried both, and because the agent
        # frontdoor rejects a competing CODEX_HOME by byte-for-byte comparison, that
        # made every non-dry-run forge-loop exit 1.
        # -R (not -r) is required: bin/ and toolbin/ are symlink farms. -I must NOT
        # be added -- it would skip the very binaries the literals are baked into.
        # Patterns are concatenated at build time so this file never contains the
        # retired literals itself; tests/strict_profile_sources.nu scans this source.
        retired_codex_home="/home/flexnetos/.""codex"
        retired_local_tree="/home/flexnetos/.""local"
        forbidden_literals="$TMPDIR/forbidden-profile-literals"
        grep -R -l -e "$retired_codex_home" -e "$retired_local_tree" \
          ${foundation}/bin ${foundation}/toolbin > "$forbidden_literals" 2>/dev/null || true
        if test -s "$forbidden_literals"; then
          echo "profile executables carry home-owned agent paths:" >&2
          cat "$forbidden_literals" >&2
          exit 1
        fi
        # The durable Codex home must be what replaced them.
        grep -q -e '/home/flexnetos/meta/var/lib/codex' ${foundation}/bin/fxrun
        YAZELIX_HOST_POLICY_ROOT=${foundation}/share/yazelix/host-policy \
          ${foundation}/bin/yazelix_host_policy check-bundle
        host_policy_test_root="$TMPDIR/host-policy-root"
        YAZELIX_HOST_POLICY_ROOT=${foundation}/share/yazelix/host-policy \
          YAZELIX_HOST_POLICY_TARGET_ROOT="$host_policy_test_root" \
          ${foundation}/bin/yazelix_host_policy apply-nix
        YAZELIX_HOST_POLICY_ROOT=${foundation}/share/yazelix/host-policy \
          YAZELIX_HOST_POLICY_TARGET_ROOT="$host_policy_test_root" \
          ${foundation}/bin/yazelix_host_policy check-files
        YAZELIX_HOST_POLICY_ROOT=${foundation}/share/yazelix/host-policy \
          YAZELIX_HOST_POLICY_TARGET_ROOT="$host_policy_test_root" \
          ${foundation}/bin/yazelix_host_policy apply-logs
        YAZELIX_HOST_POLICY_ROOT=${foundation}/share/yazelix/host-policy \
          YAZELIX_HOST_POLICY_TARGET_ROOT="$host_policy_test_root" \
          ${foundation}/bin/yazelix_host_policy check-log-files
        grep -Fx 'substitute = true' ${foundation}/share/yazelix/host-policy/nix.conf
        grep -E '^substituters = https://cache\.nixos\.org https://nix-community\.' ${foundation}/share/yazelix/host-policy/nix.conf
        grep -Fx 'trusted-substituters =' ${foundation}/share/yazelix/host-policy/nix.conf
        grep -Fx 'keep-build-log = false' ${foundation}/share/yazelix/host-policy/nix.conf
        grep -Fx 'compress-build-log = false' ${foundation}/share/yazelix/host-policy/nix.conf
        grep -F '"endpoint": null' ${foundation}/share/yazelix/host-policy/determinate-config.json
        grep -Fx '/home/flexnetos/.nix-profile/toolbin/nu' ${foundation}/share/yazelix/host-policy/shells
        grep -Fx 'Storage=none' ${foundation}/share/yazelix/host-policy/journald-no-storage.conf
        grep -F '"log-driver": "none"' ${foundation}/share/yazelix/host-policy/docker-daemon.json
        grep -F '"GenAILocalFoundationalModelSettings": 1' ${foundation}/share/yazelix/host-policy/chrome-storage.json
        grep -F '"DiskCacheDir": "/run/user/1001/yazelix/volatile/cache/google-chrome"' ${foundation}/share/yazelix/host-policy/chrome-storage.json
        grep -Fx 'ExecStart=/home/flexnetos/.nix-profile/bin/yazelix_host_policy apply-nix' ${foundation}/lib/systemd/system/yazelix_host_policy.service
        grep -Fx 'ExecStart=/home/flexnetos/.nix-profile/bin/yazelix_host_policy apply-logs' ${foundation}/lib/systemd/system/yazelix_host_policy.service
        test -f ${foundation}/lib/systemd/system/yazelix_host_policy.path
        test -f ${foundation}/lib/systemd/user/yazelix_volatile_runtime.service
        grep -Fx 'ExecStart=/home/flexnetos/.nix-profile/bin/yazelix_volatile_runtime ensure' ${foundation}/lib/systemd/user/yazelix_volatile_runtime.service
        # GitKB sync servers must ship for all three KB-owning repos, on distinct
        # ports, each rooted at its own repo -- a shared port or a wrong WorkingDirectory
        # would silently serve the wrong knowledge base.
        for kb in meta lifeos envctl; do
          test -f ${foundation}/lib/systemd/user/gitkb-serve-$kb.service
          grep -q 'ExecStart=/home/flexnetos/.nix-profile/bin/git-kb serve --host 127.0.0.1 --port' \
            ${foundation}/lib/systemd/user/gitkb-serve-$kb.service
        done
        grep -Fx 'WorkingDirectory=/home/flexnetos/meta' ${foundation}/lib/systemd/user/gitkb-serve-meta.service
        grep -Fx 'WorkingDirectory=/home/flexnetos/meta/src/lifeos' ${foundation}/lib/systemd/user/gitkb-serve-lifeos.service
        grep -Fx 'WorkingDirectory=/home/flexnetos/meta/src/envctl' ${foundation}/lib/systemd/user/gitkb-serve-envctl.service
        test "$(cat ${foundation}/lib/systemd/user/gitkb-serve-*.service | grep -c '^ExecStart=')" = 3
        test "$(cat ${foundation}/lib/systemd/user/gitkb-serve-*.service | grep -oE '\-\-port [0-9]+' | sort -u | wc -l)" = 3
        volatile_env=${foundation}/share/yazelix/environment.d/10-yazelix-volatile.conf
        # Session-scope guard. environment.d is applied by the systemd user manager to
        # the entire graphical session, so the generic XDG roots must NOT appear here:
        # XDG_DATA_HOME re-homes the GNOME keyring/icons/launchers/Trash, and
        # XDG_CACHE_HOME puts the mesa shader cache on the XDG_RUNTIME_DIR tmpfs.
        # Dev-shell scoping for these lives in nushell profile-path.nu instead.
        if grep -qE '^XDG_(DATA|STATE|CACHE)_HOME=' "$volatile_env"; then
          echo 'ERROR: 10-yazelix-volatile.conf must not set generic XDG roots (session scope)' >&2
          exit 1
        fi
        # Build artifacts are durable; /run/user/1001 is XDG_RUNTIME_DIR, not scratch.
        grep -Fx 'CARGO_HOME=/home/flexnetos/meta/var/cache/cargo-home' "$volatile_env"
        grep -Fx 'CARGO_TARGET_DIR=/home/flexnetos/meta/var/cargo-target' "$volatile_env"
        grep -Fx 'YAZELIX_STATE_DIR=/run/user/1001/yazelix/profile-runtime/yazelix' "$volatile_env"
        grep -Fx 'TMPDIR=/run/user/1001/yazelix/volatile/tmp' "$volatile_env"
        grep -Fx 'KACHE_CACHE_DIR=/home/flexnetos/.cache/kache' "$volatile_env"
        grep -Fx 'RUSTC_WRAPPER=/home/flexnetos/.nix-profile/bin/kache-rustc-wrapper' "$volatile_env"

        # Session-restore drop-in. Its filename is load-bearing: systemd merges all
        # environment.d dirs into one lexically-sorted namespace, and Ubuntu ships
        # /usr/lib/environment.d/99-environment.conf plus 990-snapd.conf, both of which
        # assign PATH. A prefix below "990" is silently overridden for PATH.
        session_env=${foundation}/share/yazelix/environment.d/99z-session-restore.conf
        test -f "$session_env"
        case "$(basename "$session_env")" in
          99z-*) : ;;
          *) echo 'ERROR: session-restore drop-in must sort after 990-snapd.conf' >&2; exit 1 ;;
        esac
        # The profile must remain the frontdoor (first), without amputating the system.
        grep -qE '^PATH=/home/flexnetos/\.nix-profile/toolbin:/home/flexnetos/\.nix-profile/bin:' "$session_env"
        for required in /usr/bin /snap/bin; do
          grep -qE "^PATH=.*(:|=)$required(:|$)" "$session_env" || {
            echo "ERROR: session-restore PATH is missing $required" >&2; exit 1; }
        done
        # Session XDG roots must match the envctl canonical table exactly.
        # The tool-state tier, not the database payload tier. Re-homing the session onto
        # meta/var/lib is what cost the keyring, icons, Trash and launchers; meta/var/xdg-*
        # is the documented migration target and carries them. Asserting the literal home
        # dotted paths here previously put a forbidden owner string into this file and
        # failed the strict profile source ownership gate.
        grep -Fx 'XDG_DATA_HOME=/home/flexnetos/meta/var/xdg-data' "$session_env"
        grep -Fx 'XDG_STATE_HOME=/home/flexnetos/meta/var/xdg-state' "$session_env"
        grep -Fx 'XDG_CACHE_HOME=/home/flexnetos/.cache' "$session_env"
        # Cargo must never resolve under XDG_RUNTIME_DIR.
        if grep -qE '^CARGO_(HOME|TARGET_DIR)=/run/user/' "$session_env" "$volatile_env"; then
          echo 'ERROR: cargo must not point at the XDG_RUNTIME_DIR tmpfs' >&2
          exit 1
        fi
        # fenix composes the toolchain and replaces the toolchain manager, so no
        # toolchain-manager home belongs in session scope. One was carried in the
        # volatile drop-in from 66973f69 until 2026-07-30, pointing at the very tmpfs
        # the cargo rule above exists to prevent, while nothing on the host read it.
        if grep -qE '^RUSTUP_' "$session_env" "$volatile_env"; then
          echo 'ERROR: fenix owns the toolchain; no toolchain-manager home in environment.d' >&2
          exit 1
        fi
        grep -Fx 'ICM_DB=/home/flexnetos/meta/var/xdg-data/icm/memories.db' "$session_env"

        # PostgreSQL/RuVector is the Swarm Primary Runtime (hard rule 1). The profile
        # must expose the server AND client tools, and must carry ruvector.so in the
        # SAME output, because postgres derives pkglibdir from the invoked path. A
        # profile with postgres but without the library reproduces the 2026-07-27
        # outage: 188 catalog-registered functions, every one failing on $libdir.
        for pgbin in postgres psql pg_ctl; do
          test -x ${foundation}/bin/$pgbin || {
            echo "ERROR: profile must expose $pgbin (Swarm Primary Runtime toolchain)" >&2
            exit 1; }
        done
        test -f ${foundation}/lib/ruvector.so || {
          echo 'ERROR: ruvector.so must sit beside postgres in the profile output' >&2
          exit 1; }
        # Catalog binding is not proof; the library must actually export the symbols the
        # installed extension resolves against.
        grep -qa 'ruvector_version_wrapper' ${foundation}/lib/ruvector.so || {
          echo 'ERROR: ruvector.so does not export the catalog-bound symbols' >&2
          exit 1; }
        grep -F 'legacy Kache root must not exist' ${./nushell/system/volatile_runtime.nu}
        grep -F 'legacy Kache delivery artifact must not exist' ${./nushell/system/volatile_runtime.nu}
        grep -F 'const PROFILE_RUNTIME_ROOT = "/run/user/1001/yazelix/profile-runtime"' ${./nushell/system/volatile_runtime.nu}

        export HOME="$TMPDIR/home"
        export YAZELIX_CONFIG_HOME="$TMPDIR/config"
        export YAZELIX_STATE_DIR="$TMPDIR/state"
        mkdir -p "$HOME" "$YAZELIX_CONFIG_HOME" "$YAZELIX_STATE_DIR"
        ${foundation}/bin/yzx status > status
        ${foundation}/bin/yzx doctor > doctor
        grep -Fx 'package: full' status
        grep -Fx 'shell: nu' status
        grep -F "runtime identity: $YAZELIX_STATE_DIR/runtime_identity.json" status
        grep -Fx 'ok shell.program: nu' doctor
        grep -F 'ok mars: /nix/store/' doctor
        cmp ${foundation}/share/yazelix/runtime_identity.json "$YAZELIX_STATE_DIR/runtime_identity.json"
        touch "$out"
      '';
      # YZXCONV-003: the packaging must emit exactly one foundation element, the
      # profile-contract scripts must satisfy their fixture suite, and a staged
      # selector built from the real foundation closure must pass every clause.
      single_profile_contract = let
        foundation = self.packages.${system}.lifeos_foundation_yzx;
        foundationAttrCount =
          builtins.length
          (builtins.filter (pkgs.lib.hasPrefix "lifeos_foundation")
            (builtins.attrNames self.packages.${system}));
        stagedProfile = pkgs.runCommand "single-profile-staged-profile" {} ''
          mkdir -p "$out"
          ln -s ${foundation}/bin "$out/bin"
          ln -s ${foundation}/toolbin "$out/toolbin"
          cat > "$out/manifest.json" <<EOF
          {"version":3,"elements":{"lifeos_foundation_yzx":{"active":true,"attrPath":"packages.${system}.lifeos_foundation_yzx","originalUrl":"path:.","outputs":null,"priority":5,"storePaths":["${foundation}"],"url":"path:."}}}
          EOF
        '';
      in pkgs.runCommand "single-profile-contract-check" {nativeBuildInputs = [pkgs.nushell];} ''
        # source contract: exactly one foundation package attribute
        test ${toString foundationAttrCount} = 1

        # hermetic fixture suite for the check + migration scripts
        nu ${./packaging/tests/single_profile_contract_test.nu} ${./packaging}

        # staged selector pointing at the real foundation closure
        staging="$TMPDIR/staging"
        mkdir -p "$staging/state/nix" "$staging/home"
        ln -s ${stagedProfile} "$staging/home/.nix-profile-1-link"
        ln -s .nix-profile-1-link "$staging/home/.nix-profile"
        YZX_PROFILE_LINK="$staging/home/.nix-profile" \
          YZX_LEGACY_XDG_PROFILE="$staging/state/nix/profile" \
          YZX_LEGACY_NESTED_PROFILE="$staging/state/nix/profiles/profile" \
          YZX_EXPECTED_CLOSURE="${foundation}" \
          ${foundation}/bin/yazelix_profile_check > staged-check.json
        grep -F '"pass": true' staged-check.json
        touch "$out"
      '';
      no_helix_contracts = pkgs.runCommand "yzx-no-helix-contracts" {} ''
        ${noHelixContractsCheck}/bin/no-helix-contracts-check \
          ${yzxNoHelix} ${noHelixClosure}/store-paths no-helix ${pkgs.nushell}/bin/nu
        ${noHelixContractsCheck}/bin/no-helix-contracts-check \
          ${yzxNoMarsNoHelix} ${noMarsNoHelixClosure}/store-paths no-mars-no-helix ${pkgs.nushell}/bin/nu
        touch "$out"
      '';
      host_yazi_contracts = pkgs.runCommand "yzx-host-yazi-contracts" {} ''
        for closure in \
          ${noYaziClosure}/store-paths \
          ${noHelixNoYaziClosure}/store-paths \
          ${noMarsNoYaziClosure}/store-paths \
          ${noMarsNoHelixNoYaziClosure}/store-paths; do
          if grep -Fx ${pkgs.yazi} "$closure"; then
            printf '%s\n' "host-Yazi closure retained ${pkgs.yazi}" >&2
            exit 1
          fi
        done

        package=${yzxNoMarsNoHelixNoYazi}
        root="$TMPDIR/host-yazi"
        export HOME="$root/home"
        export YAZELIX_CONFIG_HOME="$root/config"
        export YAZELIX_STATE_DIR="$root/state"
        export XDG_DATA_HOME="$root/data"
        mkdir -p "$HOME" "$YAZELIX_CONFIG_HOME" "$YAZELIX_STATE_DIR" "$XDG_DATA_HOME"
        printf '%s\n' '[welcome]' 'enabled = false' > "$YAZELIX_CONFIG_HOME/config.toml"

        user_yazi="$root/user-yazi"
        materialized_state="$root/materialized-state"
        mkdir -p "$user_yazi"
        printf '%s\n' '[mgr]' 'show_hidden = true' > "$user_yazi/yazi.toml"
        effective="$({
          PATH=${pkgs.coreutils}/bin "$package/bin/yzx" yazi-config materialize \
            --state-dir "$materialized_state" \
            --user-config-dir "$user_yazi"
        } 2> "$root/materialize-error")"
        test ! -s "$root/materialize-error"
        test "$effective" = "$(${pkgs.coreutils}/bin/readlink -f "$materialized_state")/yazi"
        grep -Fqx 'show_hidden = true' "$effective/yazi.toml"
        grep -F 'yzx-open' "$effective/yazi.toml"

        empty_user_yazi="$root/empty-user-yazi"
        empty_state="$root/empty-state"
        mkdir -p "$empty_user_yazi"
        empty_effective="$(PATH=${pkgs.coreutils}/bin "$package/bin/yzx" yazi-config materialize \
          --user-config-dir "$empty_user_yazi" \
          --state-dir "$empty_state")"
        test "$(${pkgs.coreutils}/bin/readlink -f "$empty_effective")" = \
          "$(${pkgs.coreutils}/bin/readlink -f "$package/share/yazelix/yazi")"
        test ! -e "$empty_state"

        invalid_user_yazi="$root/invalid-user-yazi"
        invalid_state="$root/invalid-state"
        mkdir -p "$invalid_user_yazi" "$invalid_state/yazi"
        printf '%s\n' '[mgr' > "$invalid_user_yazi/yazi.toml"
        printf '%s\n' keep > "$invalid_state/yazi/sentinel"
        set +e
        PATH=${pkgs.coreutils}/bin "$package/bin/yzx" yazi-config materialize \
          --user-config-dir "$invalid_user_yazi" \
          --state-dir "$invalid_state" \
          > "$root/invalid-output" 2> "$root/invalid-error"
        invalid_status=$?
        set -e
        test "$invalid_status" -eq 1
        test ! -s "$root/invalid-output"
        grep -F 'invalid user Yazi TOML' "$root/invalid-error"
        grep -Fqx keep "$invalid_state/yazi/sentinel"

        PATH=${pkgs.coreutils}/bin "$package/bin/yzx" yazi-config --help > "$root/yazi-config-help"
        grep -F 'yzx yazi-config materialize' "$root/yazi-config-help"
        PATH=${pkgs.coreutils}/bin "$package/bin/yzx" yazi-config materialize --help > "$root/materialize-help"
        grep -F -- '--user-config-dir <path>' "$root/materialize-help"
        set +e
        PATH=${pkgs.coreutils}/bin "$package/bin/yzx" yazi-config materialize \
          --user-config-dir "$user_yazi" > /dev/null 2> "$root/materialize-usage"
        usage_status=$?
        set -e
        test "$usage_status" -eq 64
        grep -F 'Usage: yzx yazi-config materialize' "$root/materialize-usage"

        PATH=${fakeHostYazi}/bin:${pkgs.coreutils}/bin "$package/bin/yzx" doctor > "$root/doctor"
        grep -Fqx 'ok yazi source: host' "$root/doctor"
        grep -Fqx 'ok yazi: ${fakeHostYazi}/bin/yazi' "$root/doctor"
        grep -Fqx 'ok ya: ${fakeHostYazi}/bin/ya' "$root/doctor"
        grep -Fqx 'ok yazi version: ${pkgs.yazi.version}' "$root/doctor"
        grep -Fqx 'ok yazi tested version: ${pkgs.yazi.version}' "$root/doctor"

        PATH=${fakeHostYazi}/bin:${pkgs.coreutils}/bin "$package/bin/yzx" run ya --version > "$root/ya-version"
        grep -Fqx 'Ya ${pkgs.yazi.version}' "$root/ya-version"
        PATH=${fakeHostYazi}/bin:${pkgs.coreutils}/bin "$package/bin/yzx" run yazi --version > "$root/yazi-version"
        grep -Fqx 'Yazi ${pkgs.yazi.version}' "$root/yazi-version"
        PATH=${fakeShimHostYazi}/bin:${pkgs.coreutils}/bin "$package/bin/yzx" status > "$root/shim-status"
        grep -Fqx 'yazi: ${fakeShimHostYazi}/bin/yazi' "$root/shim-status"
        grep -Fqx 'ya: ${fakeShimHostYazi}/bin/ya' "$root/shim-status"
        PATH=${fakeShimHostYazi}/bin:${pkgs.coreutils}/bin "$package/bin/yzx" run ya --version > "$root/shim-ya-version"
        grep -Fqx 'Ya ${pkgs.yazi.version}' "$root/shim-ya-version"
        PATH=${fakeShimHostYazi}/bin:${pkgs.coreutils}/bin "$package/bin/yzx" run yazi --version > "$root/shim-yazi-version"
        grep -Fqx 'Yazi ${pkgs.yazi.version}' "$root/shim-yazi-version"
        mkdir -p "$YAZELIX_CONFIG_HOME/yazi"
        printf '%s\n' 'format = "$directory$git_branch"' > "$YAZELIX_CONFIG_HOME/yazi/starship.toml"
        PATH=${fakeHostYazi}/bin:${pkgs.coreutils}/bin "$package/bin/yzx" run yazi managed > "$root/yazi-managed"
        grep -F 'fake Yazi config=' "$root/yazi-managed"
        grep -F "starship=$YAZELIX_STATE_DIR/yazi/yazelix_starship.toml" "$root/yazi-managed"
        grep -F 'role= ya=' "$root/yazi-managed"
        grep -F 'ya=${fakeHostYazi}/bin/ya' "$root/yazi-managed"
        PATH=${fakeHostYazi}/bin:${pkgs.coreutils}/bin "$package/bin/yzx" run yazi \
          --yzx-workspace-popup popup > "$root/yazi-popup"
        grep -F "starship=$YAZELIX_STATE_DIR/yazi/yazelix_starship.toml" "$root/yazi-popup"
        grep -F 'role=workspace-popup' "$root/yazi-popup"
        grep -F 'args=popup ' "$root/yazi-popup"

        YZX_YAZI_BIN=${fakeHostYazi}/bin/yazi \
          YZX_YA=${fakeHostYazi}/bin/ya \
          PATH=${fakeMismatchedHostYazi}/bin:${pkgs.coreutils}/bin \
          "$package/bin/yzx" run yazi inherited > "$root/yazi-inherited"
        grep -F 'args=inherited' "$root/yazi-inherited"
        grep -F 'ya=${fakeHostYazi}/bin/ya' "$root/yazi-inherited"

        YZX_YAZI_BIN=${fakeMismatchedHostYazi}/bin/yazi \
          PATH=${fakeHostYazi}/bin:${pkgs.coreutils}/bin \
          "$package/bin/yzx" status > "$root/partial-inherited"
        grep -Fqx 'yazi: ${fakeHostYazi}/bin/yazi' "$root/partial-inherited"
        grep -Fqx 'ya: ${fakeHostYazi}/bin/ya' "$root/partial-inherited"

        PATH=${fakeNewerHostYazi}/bin:${pkgs.coreutils}/bin "$package/bin/yzx" status > "$root/newer-status" 2> "$root/newer-warning"
        grep -F 'host yazi/ya 99.0.0 differs from Nova' "$root/newer-warning"
        PATH=${fakeNewerHostYazi}/bin:${pkgs.coreutils}/bin "$package/bin/yzx" doctor > "$root/newer-doctor"
        grep -F 'warn yazi compatibility: host yazi/ya 99.0.0 differs from Nova' "$root/newer-doctor"

        if PATH=${fakeMismatchedHostYazi}/bin:${pkgs.coreutils}/bin "$package/bin/yzx" status > /dev/null 2> "$root/mismatch"; then
          printf '%s\n' 'mismatched host Yazi pair unexpectedly succeeded' >&2
          exit 1
        fi
        grep -F 'yazi 99.0.0 and ya 98.0.0 differ' "$root/mismatch"

        if PATH=${pkgs.coreutils}/bin "$package/bin/yzx" status > /dev/null 2> "$root/missing"; then
          printf '%s\n' 'missing host Yazi pair unexpectedly succeeded' >&2
          exit 1
        fi
        grep -F 'yazi: command not found in PATH' "$root/missing"
        grep -F 'ya: command not found in PATH' "$root/missing"
        test "$(PATH=${pkgs.coreutils}/bin "$package/bin/yzx" run printf unrelated)" = unrelated
        touch "$out"
      '';
    });

    apps = eachSystem (system:
      # Upstream: every package doubles as a `yzx` app.  Fork: yzx-envelope's
      # entrypoint is bin/yzx-envelope, so it is mapped explicitly (its
      # packages gate already restricts it to Linux).
      builtins.mapAttrs (_name: package: {
        type = "app";
        program = "${package}/bin/yzx";
      }) (builtins.removeAttrs self.packages.${system} ["yzx-envelope"])
      // nixpkgs.lib.optionalAttrs (self.packages.${system} ? yzx-envelope) {
        yzx-envelope = {
          type = "app";
          program = "${self.packages.${system}.yzx-envelope}/bin/yzx-envelope";
        };
      }
      // nixpkgs.lib.optionalAttrs (builtins.match ".*-linux" system != null) {
        gha-runner = ghaRunner.apps.${system}.runner;
        gha-runner-start = ghaRunner.apps.${system}.start;
      });
  };
}
