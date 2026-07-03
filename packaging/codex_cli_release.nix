{
  pkgs,
  version,
  sha256,
  systemSuffix ? "x86_64-unknown-linux-musl",
}:

let
  packageName = "codex-package-${systemSuffix}";
  archive = pkgs.fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/${packageName}.tar.gz";
    inherit sha256;
  };
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "codex-cli";
  inherit version;
  src = archive;
  dontConfigure = true;
  dontBuild = true;
  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -R bin codex-package.json codex-path codex-resources "$out/"
    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "OpenAI Codex CLI release binary";
    license = licenses.asl20;
    mainProgram = "codex";
    platforms = [ "x86_64-linux" ];
  };
}
