{
  description = "bsnes and some games";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    bsnes-src = {
      type = "github";
      owner = "bsnes-emu";
      repo = "bsnes";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, bsnes-src }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};

      in rec {
        flakedPkgs = pkgs;

        packages.bsnes = pkgs.stdenv.mkDerivation {
          name = "bsnes";
          src = bsnes-src;
          enableParallelBuilding = true;

          nativeBuildInputs = with pkgs; [
            pkg-config
          ];

          buildInputs = with pkgs; [
            xorg.libX11.dev
            cairo
            openal
            pulseaudio.dev
            SDL2.dev
            gtk3.dev
            xorg.libXv.dev
            alsa-lib.dev
          ];

          buildPhase = ''
            make -j`nproc` -C bsnes
          '';

          installPhase = ''
            mkdir -p $out/bin
            cp bsnes/out/bsnes $out/bin
          '';
        };

        packages.default = packages.bsnes;
      }
    );
}
