{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    cargo-leptos-src = {
      url = "github:leptos-rs/cargo-leptos";
      flake = false;
    };
    leptosfmt-src = {
      url = "git+https://github.com/bram209/leptosfmt?submodules=1";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      cargo-leptos-src,
      leptosfmt-src,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

      in
      {
        flakedPkgs = pkgs;

        packages.cargo-leptos = pkgs.rustPlatform.buildRustPackage {
          name = "cargo-leptos";

          src = cargo-leptos-src;
          cargoHash = "sha256-bGOg5FfnykvzmATHLj9B02p7LHJ58waWdDarkFPx09k=";

          buildInputs = with pkgs; [
            openssl
          ];
          nativeBuildInputs = with pkgs; [
            pkg-config
            perl
          ];

          buildFeatures = [ "no_downloads" ];
          doCheck = false;
        };

        packages.leptosfmt = pkgs.rustPlatform.buildRustPackage {
          name = "leptosfmt";
          src = leptosfmt-src;

          cargoHash = "sha256-ihhEeOLNTHi0C8rGIvwiXJRiqIjWGTRRr7JLn6fMtNU=";
        };
      }
    );
}
