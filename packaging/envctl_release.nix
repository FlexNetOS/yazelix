{
  pkgs,
  envctlSource,
  loopLibSource,
  metaPluginProtocolSource,
  rustPlatform ? pkgs.rustPlatform,
}:

let
  manifest = builtins.fromTOML (builtins.readFile "${envctlSource}/Cargo.toml");
in
rustPlatform.buildRustPackage {
  pname = "envctl";
  version = manifest.workspace.package.version;
  src = envctlSource;

  cargoLock.lockFile = "${envctlSource}/Cargo.lock";
  cargoBuildFlags = [
    "-p"
    "envctl"
    "-p"
    "envctl-secretctl"
    "-p"
    "envctl-secretd"
    "--features"
    "envctl-secretd/seed-factor"
  ];
  doCheck = false;

  # envctl is a meta peer and its CLI/engine intentionally consume two sibling
  # protocol crates. Pin and place those peers inside the immutable build tree
  # so the package remains reproducible outside the live meta workspace.
  postPatch = ''
    mkdir -p vendor
    cp -R ${metaPluginProtocolSource} vendor/meta_plugin_protocol
    cp -R ${loopLibSource} vendor/loop_lib
    chmod -R u+w vendor
    for manifest in vendor/meta_plugin_protocol/Cargo.toml vendor/loop_lib/Cargo.toml; do
      substituteInPlace "$manifest" \
        --replace-fail 'version.workspace = true' 'version = "0.2.22"' \
        --replace-fail 'edition.workspace = true' 'edition = "2021"' \
        --replace-fail 'license.workspace = true' 'license = "MIT"' \
        --replace-fail 'repository.workspace = true' \
          'repository = "https://github.com/FlexNetOS/meta"'
    done
    substituteInPlace crates/cli/Cargo.toml \
      --replace-fail '../../../meta_plugin_protocol' '../../vendor/meta_plugin_protocol'
    substituteInPlace crates/engine/Cargo.toml \
      --replace-fail '../../../loop_lib' '../../vendor/loop_lib'
  '';

  postInstall = ''
    test -x "$out/bin/envctl"
    test -x "$out/bin/secretctl"
    test -x "$out/bin/secretd"
  '';

  meta = {
    description = "Profile-owned FlexNetOS environment manager and secrets broker";
    homepage = "https://github.com/FlexNetOS/envctl";
    license = with pkgs.lib.licenses; [mit asl20];
    mainProgram = "envctl";
    platforms = ["x86_64-linux"];
  };
}
