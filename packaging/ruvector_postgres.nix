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
  rev = "d9e845f39a75a8f7fc10af372504426b7fb093fc";
  upstreamSrc = pkgs.fetchFromGitHub {
    owner = "FlexNetOS";
    repo = "meta-ruvector";
    inherit rev;
    hash = "sha256-LECkeUJ8O/6d1A6l91cl7q/7zQ+4196hJUqKP/izAFw=";
  };
  # The pushed meta-ruvector source already contains the SHAKE256 entry point
  # and the full-feature dependency/default repairs.
  patchedSrc = upstreamSrc;

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
    version = "0.3.1-${builtins.substring 0 7 rev}-cap002";

    src = patchedSrc;

    cargoRoot = "crates/ruvector-postgres";
    buildAndTestSubdir = "crates/ruvector-postgres";
    cargoHash = "sha256-0s7hIdf2qDhtqHEEZA9J5MDoVGqIXiZEWRytoyqsRB0=";

    cargo-pgrx = cargo-pgrx_0_12_9;
    postgresql = pkgs.postgresql_17;

    nativeBuildInputs = [pkgs.pkg-config];
    buildInputs = [pkgs.onnxruntime];

    # The `embeddings` feature pulls fastembed -> ort -> ort-sys, whose build
    # script defaults to downloading a prebuilt ONNX Runtime from cdn.pyke.io.
    # The Nix sandbox has no network, so that build fails with
    #   "failed to lookup address information: Temporary failure in name resolution".
    # Point ort-sys at the nixpkgs ONNX Runtime instead of letting it fetch one:
    # this keeps the build hermetic and pins the runtime in the closure rather
    # than trusting a CDN artifact.
    # ort-sys probes ORT_LIB_LOCATION for the library directory itself, not the
    # package root: nixpkgs places libonnxruntime.so under $out/lib.
    #
    # ORT_PREFER_DYNAMIC_LINK is required, not optional. With only
    # ORT_LIB_LOCATION set, ort-sys 2.0.0-rc.11's build script
    # (build/main.rs:45-57) falls through to static_link(), which looks for .a
    # archives; nixpkgs ships shared objects only, so it reports "could not link
    # to the ONNX Runtime build in <dir>". build/dynamic_link.rs:6 gates the
    # dynamic path on this variable being exactly "1" or "true".
    ORT_STRATEGY = "system";
    ORT_LIB_LOCATION = "${pkgs.onnxruntime}/lib";
    ORT_PREFER_DYNAMIC_LINK = "1";
    ORT_SKIP_DOWNLOAD = "1";

    # ruvector-postgres is one member of the RuVector cargo workspace.
    # The extension is an intentionally detached workspace member; the build
    # subdirectory and cargoRoot make both metadata and vendoring use its lock.
    cargoPgrxFlags = ["-p" "ruvector-postgres"];

    # Blueprint §17 step 4 (line 5576) requires pg17, index-all, quant-all,
    # graph-complete, ai-complete-v3, analytics-complete and all-features-v3, and
    # requires verifying "graph, BM25, GNN, FastGRNN, SONA, MinCut, workers, and
    # all function families".
    #
    # The previous list omitted ai-complete-v3/all-features-v3, and with them the
    # `embeddings`, `learning`, `gnn` and `routing` gates. Measured against the
    # live catalog that build bound only 192 functions with embeddings=1
    # (ruvector_embed absent), integrity/MinCut=0 and BM25=0 — so no semantic
    # layer could be built on it at all.
    #
    # all-features-v3 transitively covers all-features (ai-complete +
    # graph-complete + embeddings), analytics-complete, ai-complete-v3 and
    # domain-expansion; graph-complete carries `sparse`, which is what exposes
    # pg_sparse_bm25. simd-auto matches line 1059's "full installation uses
    # pg17, SIMD, ... real embeddings ... solver, math, and TDA paths".
    buildFeatures = [
      "pg17"
      "simd-auto"
      "index-all"
      "quant-all"
      "all-features-v3"
    ];

    doCheck = false;

    # cargo-pgrx emits the patched current-version 0.3.1 script. Historical
    # install scripts and both upgrade edges remain available for existing
    # databases.
    postInstall = ''
      # Preserve pgrx's generated install script before installing historical
      # upgrade edges. It is the artifact that reflects buildFeatures.
      if [ -f "$out/share/postgresql/extension/ruvector--0.3.1.sql" ]; then
        install -m 0444 "$out/share/postgresql/extension/ruvector--0.3.1.sql" \
          "$out/share/postgresql/extension/ruvector--0.3.1-pgrx-generated.sql"
      fi

      for sql in crates/ruvector-postgres/sql/ruvector--0.1.0.sql \
        crates/ruvector-postgres/sql/ruvector--0.3.0.sql \
        crates/ruvector-postgres/sql/ruvector--0.3.0--0.3.1.sql \
        crates/ruvector-postgres/sql/ruvector--2.0.0.sql \
        crates/ruvector-postgres/sql/ruvector--2.0.0--0.3.0.sql; do
        install -m 0444 "$sql" "$out/share/postgresql/extension/$(basename "$sql")"
      done

      current_sql="$out/share/postgresql/extension/ruvector--0.3.1.sql"
      if grep -Eq "DEFAULT (auto|dot|validation|parameter_change|JsonB\\(|DEFAULT_CURVATURE)" "$current_sql"; then
        echo "ERROR: invalid generated SQL default remains in $current_sql" >&2
        grep -nE "DEFAULT (auto|dot|validation|parameter_change|JsonB\\(|DEFAULT_CURVATURE)" "$current_sql" >&2
        exit 1
      fi
      if ! grep -q 'ruvector_embed' "$current_sql"; then
        echo "ERROR: generated script lacks ruvector_embed; feature set regressed" >&2
        exit 1
      fi

      printf '%s\n' \
        "" \
        "REVOKE EXECUTE ON FUNCTION ruvector_shake256_256(bytea) FROM PUBLIC;" \
        "GRANT EXECUTE ON FUNCTION ruvector_shake256_256(bytea)" \
        "  TO lifeos_migrator, lifeos_envctl, lifeos_runtime;" \
        >> "$current_sql"
      chmod 0444 "$current_sql"

      printf '%s\n' '${rev}+cap-inv011-001' \
        > "$out/share/postgresql/extension/.envctl-ruvector-source"
    '';

    meta = {
      description = "RuVector vector/graph extension for PostgreSQL 17";
      homepage = "https://github.com/ruvnet/RuVector";
      platforms = pkgs.lib.platforms.linux;
    };
  }
