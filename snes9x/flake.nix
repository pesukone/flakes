{
  description = "snes9x and some games";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    snes9x-src = {
      url = "git+https://github.com/snes9xgit/snes9x?submodules=1";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, snes9x-src }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};

      in rec {
        flakedPkgs = pkgs;

        packages.snes9x = pkgs.stdenv.mkDerivation {
          name = "snes9x";
          src = snes9x-src;
          enableParallelBuilding = true;

          nativeBuildInputs = with pkgs; [
            cmake
            ninja
            pkg-config
            wrapGAppsHook3
            python3
          ];

          buildInputs = with pkgs; [
            SDL2.dev
            gtkmm3.dev
            libpng.dev
            xorg.libXv.dev
            xorg.libXdmcp
            libsysprof-capture
            spirv-tools
            pulseaudio.dev
            portaudio
            alsa-lib.dev
            libepoxy.dev
            xorg.libX11.dev
            minizip
            zlib.dev
            xorg.libXrandr.dev
            pcre2.dev
          ];

          preConfigure = ''
            cd gtk
          '';

          cmakeFlags = [
            "-DCMAKE_BUILD_TYPE=Release"
            #"-S ."
            "-B build"
          ];

          preBuild = ''
            cd build
          '';

          installPhase = ''
            mkdir -p $out/bin
            cp snes9x-gtk $out/bin/snes9x
          '';
        };

        packages.default = packages.snes9x;
      }
    );
}
