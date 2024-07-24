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

        packages.sm-exe = pkgs.stdenv.mkDerivation {
          name = "sm-exe";
          src = sm-src;
          enableParallelBuilding = true;
          buildInputs = with pkgs; [
            SDL2
          ];

          installPhase = ''
            mkdir -p $out/bin
            cp sm $out/bin/sm-exe
            cp ${self}/sm.ini $out/bin/
          '';
        };

        packages.default = pkgs.writeShellApplication {
          name = "sm";
          runtimeInputs = [ packages.sm-exe ];

          text = ''
            sm-exe ~/roms/sm.smc
          '';
        };
      }
    );
}
