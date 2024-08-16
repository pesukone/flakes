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

    freedoom-src = {
      type = "github";
      owner = "freedoom";
      repo = "freedoom";
      flake = false;
    };

    deutex-src = {
      type = "github";
      owner = "Doom-Utils";
      repo = "deutex";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    dsda-src,
    freedoom-src,
    deutex-src
  }:
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

        packages.freedoom-wads = pkgs.stdenv.mkDerivation {
          name = "freedoom-wads";
          src = freedoom-src;

          nativeBuildInputs = with pkgs; [
            packages.deutex
            python3
            asciidoc
            asciidoctor
            (pkgs.python3.withPackages (python-pkgs: [
              python-pkgs.pillow
            ]))
          ];

          preBuild = ''
            patchShebangs \
            scripts/simplecpp \
            graphics/text/textgen \
            graphics/text/tint.py \
            graphics/text/smtextgen \
            graphics/text/rotate \
            graphics/text/create_caption \
            lumps/playpal/playpal \
            lumps/colormap/colormap \
            lumps/genmidi/mkgenmidi \
            lumps/dmxgus/gen-ultramid \
            lumps/textures/build-textures \
            bootstrap/bootstrap \
            dist/pillow-resize \
            dist/pillow-compose
          '';

          DESTDIR = "$(out)";
        };

        packages.deutex = pkgs.stdenv.mkDerivation {
          name = "deutex";
          src = deutex-src;

          nativeBuildInputs = with pkgs; [
            pkg-config
            autoreconfHook
            libpng.dev
          ];
        };

        packages.default = packages.dsda-doom;
      }
    );
}
