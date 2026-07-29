{
  pkgs,
  agentSource,
  rustPlatform ? pkgs.rustPlatform,
}:

let
  manifest = builtins.fromTOML (builtins.readFile "${agentSource}/Cargo.toml");
in
rustPlatform.buildRustPackage {
  pname = "agent";
  version = manifest.package.version;

  src = agentSource;

  cargoLock.lockFile = "${agentSource}/Cargo.lock";
  doCheck = false;

  meta = with pkgs.lib; {
    description = "FlexNetOS agent CLI; supplies the `agent guard` PreToolUse policy engine";
    homepage = "https://github.com/FlexNetOS/agent";
    license = licenses.asl20;
    mainProgram = "agent";
    platforms = [ "x86_64-linux" ];
  };
}
