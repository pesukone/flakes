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

    sunlust-zip = {
      url = "https://ftpmirror1.infania.net/pub/idgames/levels/doom2/Ports/megawads/sunlust.zip";
      flake = false;
    };

    soundfont = {
      url = "https://archive.org/download/SC55EmperorGrieferus/Roland%20SC-55%20v3.7.sf2";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    dsda-src,
    freedoom-src,
    deutex-src,
    soundfont,
    sunlust-zip
  }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        config = pkgs.writeText "dsda-doom.conf" ''
          snd_soundfont "${soundfont}"

          use_fullscreen 1
          exclusive_fullscreen 1
          gl_exclusive_fullscreen 1
        '';

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

        packages.doom = pkgs.writeShellApplication {
          name = "doom";
          runtimeInputs = [ packages.dsda-doom ];

          text = ''
            dsda-doom -config ${config} -iwad ~/roms/doom/doom.wad
          '';
        };

        packages.doom2 = pkgs.writeShellApplication {
          name = "doom2";
          runtimeInputs = [ packages.dsda-doom ];

          text = ''
            dsda-doom -config ${config} -iwad ~/roms/doom/doom2.wad
          '';
        };

        packages.tnt = pkgs.writeShellApplication {
          name = "tnt";
          runtimeInputs = [ packages.dsda-doom ];

          text = ''
            dsda-doom -config ${config} -iwad ~/roms/doom/tnt.wad
          '';
        };

        packages.plutonia = pkgs.writeShellApplication {
          name = "plutonia";
          runtimeInputs = [ packages.dsda-doom ];

          text = ''
            dsda-doom -config ${config} -iwad ~/roms/doom/plutonia.wad
          '';
        };

        packages.nerve = pkgs.writeShellApplication {
          name = "no rest for the living";
          runtimeInputs = [ packages.dsda-doom ];

          text = ''
            dsda-doom -config ${config} -iwad ~/roms/doom/doom2.wad -file ~/roms/doom/nerve.wad
          '';
        };

        packages.lor = pkgs.writeShellApplication {
          name = "legacy of rust";
          runtimeInputs = [ packages.dsda-doom ];

          text = ''
            dsda-doom -config ${config} -iwad ~/roms/doom/doom2.wad -file ~/roms/doom/id1.wad
          '';
        };

        /*
        packages.freedoom1 = pkgs.writeShellApplication {
          name = "freedoom";
          runtimeInputs = [
            packages.dsda-doom
          ];

          text = ''
            ls ${packages.freedoom-wads}/usr/local/bin
            dsda-doom -iwad ~/roms/doom/doom.wad -file ${packages.freedoom-wads}/usr/local/bin/freedoom1
          '';
        };
        */

        packages.sunlust = pkgs.writeShellApplication {
          name = "sunlust";
          runtimeInputs = [ packages.dsda-doom ];

          text = ''
            dsda-doom -config ${config} -iwad ~/roms/doom/doom2.wad -file ${sunlust-zip}/sunlust.wad
          '';
        };

        packages.default = packages.dsda-doom;
      }
    );
}
