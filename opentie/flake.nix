{
  description = "OpenTIE";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    opentie-src = {
      url = "git+https://github.com/elyosh/OpenTIE?submodules=1";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      opentie-src,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      rec {
        packages.opentie = pkgs.stdenv.mkDerivation {
          name = "opentie";
          src = opentie-src;
          enableParallelBuilding = true;

          patches = [ ./add-new-include.patch ];

          nativeBuildInputs = with pkgs; [
            cmake
            pkg-config
          ];

          buildInputs = with pkgs; [
            sdl3
            (sdl3-shadercross.overrideAttrs (
              finalAttrs: previousAttrs: {
                patches = (previousAttrs.patches or [ ]) ++ [
                  "${opentie-src}/packaging/common/shadercross-fsr3.patch"
                ];
              }
            ))
            zstd
            ffmpeg
            alsa-lib
            fluidsynth
          ];

          installPhase = ''
            runHook preInstall

            install -Dm755 OpenTIE "$out/bin/OpenTIE"
            install -d "$out/bin/shaders"
            cp shaders/* "$out/bin/shaders/"
            cp -r resources "$out/bin/resources"

            runHook postInstall
          '';

          meta.mainProgram = "OpenTIE";
        };

        packages.default = packages.opentie;
      }
    );
}
