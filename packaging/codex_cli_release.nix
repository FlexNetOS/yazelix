{
  pkgs,
  version,
  system ? pkgs.stdenv.hostPlatform.system,
  releases ? {
    x86_64-linux = {
      systemSuffix = "x86_64-unknown-linux-musl";
      sha256 = "sha256-caKNNiyWrJgpv4IDoscb5FGutyatuEMWf9rw6uj+fdk=";
    };
    aarch64-linux = {
      systemSuffix = "aarch64-unknown-linux-musl";
      sha256 = "sha256-VPeaBaum+av475iKvK6L8vzvuiC+tUm0/ys6zbLLb1Q=";
    };
    x86_64-darwin = {
      systemSuffix = "x86_64-apple-darwin";
      sha256 = "sha256-nUAsnKgUZV/dwHtUjXCGSRwK/Ovh90bN66EEX9b2JkY=";
    };
    aarch64-darwin = {
      systemSuffix = "aarch64-apple-darwin";
      sha256 = "sha256-7Ok3Fp1MnpENYIJqbqSueEihbAiUA9Ei5w59pKxBujQ=";
    };
  },
}:

let
  release =
    releases.${system} or (throw "unsupported Codex release system for Yazelix foundation: ${system}");
  packageName = "codex-package-${release.systemSuffix}";
  archive = pkgs.fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/${packageName}.tar.gz";
    inherit (release) sha256;
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
    platforms = builtins.attrNames releases;
  };
}
