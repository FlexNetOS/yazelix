{
  # FlexNetOS self-hosted GitHub runner — rUv-native agent runner, pure Nix flake.
  #
  # HARD CONSTRAINT: ZERO OS system dependencies. No systemd, no host services, no
  # apt/host packages, no tsc build. Everything is in the Nix closure. The runner is
  # a metaharness harness (@metaharness/kernel + @metaharness/host-github-actions),
  # shipped as plain ESM `bin/cli.js` (no build step), executed by node from the flake.
  #
  # Grounded in rUv source:
  #   metaharness/docs/adrs/ADR-033-host-github-actions.md  (GHA host adapter, --gha-mode)
  #   ruv-drone/agent-harness/bin/cli.js                    (plain-ESM harness bin, no build)
  #   metaharness packages/create-agent-harness/package.json (v0.4.1, bin: metaharness/harness)
  description = "FlexNetOS rUv-native self-hosted GitHub runner (metaharness, hermetic Nix, no OS deps)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAll = f: nixpkgs.lib.genAttrs systems (system: f system nixpkgs.legacyPackages.${system});
    in
    {
      # The metaharness CLI, built hermetically from npm (no OS deps, no global install).
      packages = forAll (system: pkgs: {
        metaharness = pkgs.buildNpmPackage {
          pname = "metaharness";
          version = "0.4.1";
          src = ./harness;
          # dontNpmBuild: the harness bin/cli.js is plain ESM — no tsc build step.
          dontNpmBuild = true;
          # Filled by the first `nix build` (nix prints the correct hash on mismatch).
          npmDepsHash = nixpkgs.lib.fakeHash;
          nativeBuildInputs = [ pkgs.nodejs ];
          meta.description = "FlexNetOS metaharness runner harness (github-actions host)";
        };
        default = self.packages.${system}.metaharness;
      });

      # Apps — all launched via nix, PATH from the closure only.
      apps = forAll (system: pkgs:
        let
          nu = "${pkgs.nushell}/bin/nu";
          runnerScript = ./scripts/runner.nu;
        in
        {
          # One-time (network) scaffold of the FlexNetOS harness targeting the github-actions host.
          # Runtime uses bun (bunx) per FlexNetOS convention — never bare npx/node.
          scaffold = {
            type = "app";
            program = toString (pkgs.writeShellScript "mh-scaffold" ''
              exec ${pkgs.bun}/bin/bunx metaharness@0.4.1 scaffold \
                --name flexnetos-runner --hosts github-actions "$@"
            '');
          };
          # Register + run the runner (Nushell, envctl-minted token, zero OS deps).
          runner = {
            type = "app";
            program = toString (pkgs.writeShellScript "mh-runner" ''
              exec ${nu} ${runnerScript} "$@"
            '');
          };
          # Offline gate harness (bun run, never bare node).
          verify = {
            type = "app";
            program = toString (pkgs.writeShellScript "mh-verify" ''
              exec ${pkgs.bun}/bin/bun run ${./verify.mjs} "$@"
            '');
          };
          default = self.apps.${system}.runner;
        });

      # Hermetic dev shell: bun + node (buildNpmPackage only) + nushell + gh, nothing from the host OS.
      devShells = forAll (system: pkgs: {
        default = pkgs.mkShell {
          packages = [ pkgs.bun pkgs.nodejs pkgs.nushell pkgs.gh ];
          shellHook = ''
            echo "FlexNetOS gha-runner devshell — bun $(bun --version), nu $(nu --version | head -1)"
          '';
        };
      });
    };
}
