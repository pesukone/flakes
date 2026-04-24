{
  description = "switchres flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    switchres-src = {
      url = "github:antonioginer/switchres";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      switchres-src,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      rec {
        flakedPkgs = pkgs;

        packages.switchres = pkgs.stdenv.mkDerivation {
          name = "switchres";
          src = switchres-src;

          nativeBuildInputs = with pkgs; [
            pkg-config
          ];

          buildInputs = with pkgs; [
            SDL
            SDL2
            libdrm
            libx11
          ];

          patchPhase = ''
            runHook prePatch

            substituteInPlace ./custom_video_drmkms.cpp \
              --replace-fail libdrm.so ${pkgs.libdrm}/lib/libdrm.so \

            runHook postPatch
          '';

          installPhase = ''
            install -Dm755 switchres $out/bin/switchres
          '';
        };

        packages.default = packages.switchres;
      }
    );
}
