{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    vacuumtube-src = {
      url = "github:shy1132/VacuumTube";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      vacuumtube-src,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      rec {
        packages.vacuumtube = pkgs.buildNpmPackage (finalAttrs: {
          pname = "vacuumtube";
          version = "1.8.1";

          env.ELECTRON_SKIP_BINARY_DOWNLOAD = 1;

          src = vacuumtube-src;
          npmDepsHash = "sha256-Q/E+Rc9CuaN2cN6AKKT3EHiR97sdLAAnks5DYBQK24I=";

          buildInputs = with pkgs; [
            glib
            ffmpeg
          ];

          buildPhase = ''
            runHook preBuild

            npm exec electron-builder -- \
            --dir \
            -c.electronDist=${pkgs.electron_42.dist} \
            -c.electronVersion=${pkgs.electron_42.version}

            runHook postBuild
          '';

          /*
                    desktopItems = [
                      (pkgs.makeDesktopItem {
                        name = finalAttrs.pname;
                        desktopName = "VacuumTube";
                        genericName = "Video Player";
                        comment = finalAttrs.meta.description;
                        icon = "vacuumtube";
                        exec = finalAttrs.meta.mainProgram;
                        terminal = false;
                      })
                    ];
          */

          installPhase = ''
            runHook preInstall

            for i in 16 32 48 64 128 256 512; do
              install -Dm644 "assets/icons/$i"x"$i.png" "$out/share/icons/hicolor/$i"x"$i/apps/vacuumtube.png"
            done

            cp -r dist/linux-unpacked "$out/share/vacuumtube/";
            makeWrapper "$out/share/vacuumtube/vacuumtube" "$out/bin/vacuumtube" \
              --set LD_LIBRARY_PATH "$out/share/vacuumtube" \
              --add-flags "--no-sandbox" #--disable-gpu"

            runHook postInstall
          '';

          meta = {
            description = "VacuumTube";
            mainProgram = "vacuumtube";
          };
        });

        packages.default = packages.vacuumtube;
      }
    );
}
