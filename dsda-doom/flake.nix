{
  description = "dsda-doom flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    dsda-src = {
      type = "github";
      owner = "kraflab";
      repo = "dsda-doom";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, dsda-src }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};

      in rec {
        packages.dsda-doom = pkgs.stdenv.mkDerivation {
          name = "dsda-doom";
          src = dsda-src;

          nativeBuildInputs = with pkgs; [ cmake ];

          buildInputs = with pkgs; [
            libGLU
            libzip
            SDL2
            SDL2_mixer
          ];

          sourceRoot = "source/prboom2";
        };

        packages.default = packages.dsda-doom;
      }
    );
}
