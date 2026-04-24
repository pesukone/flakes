{
  description = "dolphin flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    dolphin-src = {
      url = "git+https://github.com/dolphin-emu/dolphin?submodules=1";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      dolphin-src,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      rec {
        flakedPkgs = pkgs;

        packages.dolphin-emu = pkgs.stdenv.mkDerivation {
          name = "dolphin-emu";
          src = dolphin-src;

          nativeBuildInputs = with pkgs; [
            cmake
            pkg-config
            perl
            qt6.wrapQtAppsHook
          ];

          buildInputs = with pkgs; [
            libGL
            egl-wayland
            ffmpeg
            libevdev
            fmt
            glslang
            pugixml
            enet
            xxhash
            bzip2
            zstd
            zlib
            minizip-ng
            lzo
            lz4
            libspng
            cubeb
            qt6.qtbase
            qt6.qtsvg
            bluez
            llvm
            pulseaudio
            alsa-lib
            gtest
            systemd
            crc32c
            #mgba
            discord-rpc
            hidapi
            curl
            python3
            mbedtls
            miniupnpc
            sfml
            sdl3
            libusb1
          ];

          cmakeFlags = [
            "-DENABLE_X11=OFF"
          ];
        };

        packages.default = packages.dolphin-emu;
      }
    );
}
