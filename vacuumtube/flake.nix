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
          version = "1.8.0";

          env.ELECTRON_SKIP_BINARY_DOWNLOAD = 1;

          src = vacuumtube-src;
          npmDepsHash = "sha256-hbSN5I3LG4+y0Ggkv5C1zsaLYbrFjGXiwURfc51d0Kk=";

          buildPhase = ''
            runHook preBuild

            npm exec electron-builder -- \
            --dir \
            -c.electronDist=${pkgs.electron.dist} \
            -c.electronVersion=${pkgs.electron.version}

            runHook postBuild
          '';

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

          installPhase = ''
            runHook preInstall

            for i in 16 32 48 64 128 256 512; do
              install -Dm644 "assets/icons/$i"x"$i.png" "$out/share/icons/hicolor/$i"x"$i/apps/vacuumtube.png"
            done

            cp -r dist/linux-unpacked "$out/share/vacuumtube";

            runHook postInstall
          '';

          postFixup = ''
            patchelf \
              --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
              --set-rpath ""
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
