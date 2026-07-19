{
  description = "KeeperFX";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    keeperfx-src = {
      url = "git+https://github.com/dkfans/keeperfx?submodules=1";
      flake = false;
    };

    centijson-src = {
      url = "file+https://github.com/dkfans/kfx-deps/releases/download/20260608/centijson-lin64.tar.gz";
      flake = false;
    };
    enet-src = {
      url = "file+https://github.com/dkfans/kfx-deps/releases/download/20260608/enet6-lin64.tar.gz";
      flake = false;
    };
    spng-src = {
      url = "file+https://github.com/dkfans/kfx-deps/releases/download/20260608/spng-mingw64.tar.gz";
      flake = false;
    };
    astronomy-src = {
      url = "file+https://github.com/dkfans/kfx-deps/releases/download/20260608/astronomy-lin64.tar.gz";
      flake = false;
    };
    zlib-src = {
      url = "file+https://github.com/dkfans/kfx-deps/releases/download/20260608/zlib-mingw64.tar.gz";
      flake = false;
    };
    libcurl-src = {
      url = "file+https://github.com/dkfans/kfx-deps/releases/download/20260608/libcurl-lin64.tar.gz";
      flake = false;
    };

    png2ico-src = {
      url = "github:dkfans/png2ico";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      keeperfx-src,
      centijson-src,
      enet-src,
      spng-src,
      astronomy-src,
      zlib-src,
      libcurl-src,
      png2ico-src,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      rec {
        packages.png2ico = pkgs.stdenv.mkDerivation {
          name = "png2ico";
          src = png2ico-src;

          buildInputs = with pkgs; [
            libspng
          ];

          installPhase = ''
            mkdir -p $out/bin
            mkdir -p $out/share/man/man1

            cp png2ico $out/bin
            cp doc/man1/png2ico.1 $out/share/man/man1
          '';
        };

        packages.keeperfx = pkgs.stdenv.mkDerivation {
          name = "keeperfx";
          src = keeperfx-src;
          enableParallelBuilding = true;

          nativeBuildInputs = with pkgs; [
            pkg-config
          ];

          buildInputs = with pkgs; [
            git
            SDL2.dev
            SDL2_image.dev
            SDL2_mixer.dev
            SDL2_net.dev
            libwebp
            libtiff
            curl
            libx11
            luajit
            openal
            ffmpeg
            libspng
            minizip
            miniupnpc
            libnatpmp
          ];

          NIX_CFLAGS_COMPILE = [
            "-Wno-absolute-value"
            "-Wno-format-truncation"
            "-Wno-error"
            "-I${pkgs.SDL2.dev}/include/SDL2"
          ];
          NIX_LDFLAGS = [
            "-L${pkgs.SDL2.dev}/lib"
          ];

          postUnpack = ''
            mkdir -p source/deps
            cp ${centijson-src} source/deps/centijson-lin64.tar.gz
            cp ${enet-src} source/deps/enet6-lin64.tar.gz
            cp ${astronomy-src} source/deps/astronomy-lin64.tar.gz
            cp ${libcurl-src} source/deps/libcurl-lin64.tar.gz

            #cp ${spng-src} source/deps/spng-mingw64.tar.gz


            #cp -r ${zlib-src}/* source/deps/zlib 

            mkdir -p source/tools/png2ico/Linux
            cp ${packages.png2ico}/bin/png2ico source/tools/png2ico/Linux
          '';

          preConfigure = ''
            make -f linux.mk src/ver_defs.h
          '';

          buildPhase = ''
            make -f linux.mk -j $nproc
          '';

          installPhase = ''
            ls -l
            exit 1
            mkdir -p $out/bin
            cp bin/keeperfx $out/bin
          '';
        };

        packages.default = packages.keeperfx;
      }
    );
}
