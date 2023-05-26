{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    naersk.url = "github:nix-community/naersk";

    nixpkgs-mozilla = {
      url = "github:mozilla/nixpkgs-mozilla";
      flake = false;
    };
  };

  outputs = { self, flake-utils, naersk, nixpkgs, nixpkgs-mozilla }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = (import nixpkgs) {
          inherit system;

          overlays = [
            (import nixpkgs-mozilla)
          ];
        };

        toolchain = (pkgs.rustChannelOf {
          rustToolchain = ./rust-toolchain.toml;
          sha256 = "sha256-H98015FIIH3DZs1x6Lm830UTAGtVWYFnBrZl0r9i4+g="; # After you run `nix build`, replace this with the actual hash from the error message
        }).rust;

        naersk' = pkgs.callPackage naersk {
          cargo = toolchain;
          rustc = toolchain;

        };

      in  rec {
        # For `nix build` & `nix run`:

        # Build binary
        packages.nix-hello-world = naersk'.buildPackage {

            name = "nix-hello-world";# make this what ever your cargo.toml package.name is
            version = "0.1.0";
            root = ./.; # the folder with the Cargo.toml

            nativeBuildInputs = with pkgs; [ pkg-config ]; # just for the host building the package

            buildInputs = with pkgs; [ openssl ]; # packages needed by the consumer

            # cargoLock.lockFile = ./Cargo.lock;

        };

        # Build docker
        packages.nix-docker-hello = pkgs.dockerTools.buildImage {
          name = "nix-hello-world";
          config = { Cmd = [ "${packages.nix-hello-world}/bin/nix-hello-world" ]; };
        };
         # The package that gets built when I run 'nix build`
        defaultPackage =  packages.nix-hello-world;

        # For `nix develop` (optional, can be skipped):
        devShell = pkgs.mkShell {
          nativeBuildInputs = [
            toolchain
            pkgs.rust-analyzer-unwrapped # wrapped comes with nixpkgs, we want the unwrapped one

          ];

          RUST_SRC_PATH = "${toolchain}/lib/rustlib/src/rust/library";

        };
      }
    );
}
