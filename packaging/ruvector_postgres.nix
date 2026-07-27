# RuVector, the PostgreSQL extension half of the Swarm Primary Runtime
# (blueprint hard rule 1), built from fetched source.
#
# This recipe was recovered from the build receipt of the extension the live
# cluster actually runs on -- nix kept the .drv after the expression that
# produced it was lost:
#
#     /nix/store/4xk1yw7q4m0dvfnj95wp9sykjwff5p5m-ruvector-postgres-0.3.0-5f0a2c2.drv
#
# Every hash, feature flag and postInstall step below is transcribed from that
# derivation, so a build here reproduces the library the catalog is already
# bound to. `git log -S ruvector-postgres -- '*.nix'` over meta, envctl,
# yazelix, meta-ruvector and lifeos returns nothing: the original was built ad
# hoc and never committed, which is why the flake had to reference the output
# by builtins.storePath and why every rebuild needed --impure.
{
  pkgs,
  buildPgrxExtension ? pkgs.buildPgrxExtension,
  rustPlatform ? pkgs.rustPlatform,
}: let
  rev = "5f0a2c2cc049dfe35f142cd58ab8c966bedef785";

  # ruvector-postgres' Cargo.lock pins pgrx 0.12.9 exactly and cargo-pgrx has to
  # match the pgrx crate version, but nixpkgs only pins 0.12.6. Re-point the
  # 0.12.6 package at the 0.12.9 crate release; cargoDeps has to be replaced
  # alongside src because buildRustPackage consumes cargoHash at construction.
  cargo-pgrx_0_12_9 = pkgs.cargo-pgrx_0_12_6.overrideAttrs (old: rec {
    version = "0.12.9";
    # Verified rather than copied: this is `nix hash path` of the very source tree
    # the original cargo-pgrx build consumed, so the fetch is bit-identical to it.
    src = pkgs.fetchCrate {
      pname = "cargo-pgrx";
      inherit version;
      hash = "sha256-aR3DZAjeEEAjLQfZ0ZxkjLqTVMIEbU0UiZ62T4BkQq8=";
    };
    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit src;
      name = "cargo-pgrx-${version}-vendor";
      hash = "sha256-yZpD3FriL9UbzRtdFkfIfFfYIrRPYxr/lZ5rb0YBTPc=";
    };
  });
in
  buildPgrxExtension {
    pname = "ruvector-postgres";
    version = "0.3.0-${builtins.substring 0 7 rev}";

    src = pkgs.fetchFromGitHub {
      owner = "ruvnet";
      repo = "RuVector";
      inherit rev;
      hash = "sha256-bPdccVQjGlMMJ9/6gOoS3VemY3ubE3JrFwtiAqYEnFs=";
    };

    cargoHash = "sha256-z8zeB5gsgXcOd6CPp9BjtyotJB67FuYpmyOIBa6KCUg=";

    cargo-pgrx = cargo-pgrx_0_12_9;
    postgresql = pkgs.postgresql_17;

    # ruvector-postgres is one member of the RuVector cargo workspace.
    cargoPgrxFlags = ["-p" "ruvector-postgres"];

    # This exact feature set is what makes the build satisfy all 188 symbols the
    # live catalog binds; a narrower build resolves only 146 of them.
    buildFeatures = [
      "pg17"
      "index-all"
      "quant-all"
      "graph-complete"
      "gated-transformer"
      "analytics-complete"
      "attention-extended"
      "sona-learning"
      "domain-expansion"
    ];

    doCheck = false;

    # cargo-pgrx emits only the current version script. The extra scripts and the
    # 2.0.0 -> 0.3.0 upgrade path ship from the repo so an existing database can
    # still resolve CREATE EXTENSION / ALTER EXTENSION UPDATE.
    postInstall = ''
      for sql in crates/ruvector-postgres/sql/ruvector--0.1.0.sql \
        crates/ruvector-postgres/sql/ruvector--0.3.0.sql \
        crates/ruvector-postgres/sql/ruvector--2.0.0.sql \
        crates/ruvector-postgres/sql/ruvector--2.0.0--0.3.0.sql; do
        install -m 0444 "$sql" "$out/share/postgresql/extension/$(basename "$sql")"
      done
      printf '%s\n' ${rev} \
        > "$out/share/postgresql/extension/.envctl-ruvector-source"
    '';

    meta = {
      description = "RuVector vector/graph extension for PostgreSQL 17";
      homepage = "https://github.com/ruvnet/RuVector";
      platforms = pkgs.lib.platforms.linux;
    };
  }
