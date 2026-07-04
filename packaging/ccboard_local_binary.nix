{
  pkgs,
  version ? "local",
  binaryPath ? builtins.getEnv "FLEXNETOS_CCBOARD_PATH",
}:

let
  resolvedBinaryPath =
    if binaryPath == "" then
      throw "FLEXNETOS_CCBOARD_PATH must point at the ccboard binary when building the FlexNetOS foundation package"
    else
      /. + binaryPath;
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "ccboard";
  inherit version;
  src = resolvedBinaryPath;
  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    install -m 755 "$src" "$out/bin/ccboard"
    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "ccboard Claude Code dashboard packaged from the current FlexNetOS local binary";
    license = licenses.mit;
    mainProgram = "ccboard";
    platforms = [ "x86_64-linux" ];
  };
}
