{
  description = "flake for building the pc port of sm";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    sm-src = {
      type = "github";
      owner = "snesrev";
      repo = "sm";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, sm-src }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

      in rec {
        flakedPkgs = pkgs;

        packages.default = pkgs.stdenv.mkDerivation {
          name = "sm";
          src = sm-src;
          enableParallelBuilding = true;
          buildInputs = with pkgs; [
            SDL2
          ];

          installPhase = ''
            mkdir -p $out/bin
            cp sm $out/bin
            cp sm.ini $out
          '';
        };
      }
    );
}
