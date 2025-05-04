{
  description = "mythtv flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    mythtv-src = {
      url = "https://github.com/MythTV/mythtv/archive/refs/tags/v35.0.tar.gz";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      mythtv-src,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

      in
      rec {
        flakedPkgs = pkgs;

        packages.mythffmpeg = pkgs.stdenv.mkDerivation {
          name = "mythffmpeg";
          src = "${mythtv-src}/mythtv/external/FFmpeg";

          enableParallelBuilding = true;

          nativeBuildInputs = with pkgs; [
            yasm
          ];

          dontDisableStatic = true;
        };

        packages.mythtv = pkgs.stdenv.mkDerivation {
          name = "mythtv";
          src = mythtv-src;

          broken = true;

          enableParallelBuilding = true;

          postPatch = ''
            substituteInPlace cmake/GetLinuxInfo.cmake \
              --replace-fail "get_lsb_info()" ""

            substituteInPlace CMakeLists.txt \
              --replace-fail "mythtv_find_source_version(MYTHTV_SOURCE_VERSION MYTHTV_SOURCE_VERSION_MAJOR" "" \
              --replace-fail "MYTHTV_SOURCE_BRANCH)" ""

            substituteInPlace mythtv/cmake/BuildSystemLinux.cmake \
              --replace-fail "print_build_name()" ""
          '';

          nativeBuildInputs = with pkgs; [
            pkg-config
            cmake
            ninja
            yasm
            #kdePackages.wrapQtAppsHook
            #kdePackages.qmake
          ];

          buildInputs = with pkgs; [
            #kdePackages.qtbase
            pkg-config
            expat.dev
            zlib.dev
            bzip2.dev
            libpng.dev
            brotli.dev
            freetype.dev
            libxml2.dev
            libbluray
            fontconfig.dev
            lame
            libvpx.dev
            libvdpau.dev
            libva.dev
            libass.dev
            dav1d.dev
            libaom.dev
            gnutls.dev
            libiec61883
            libavc1394
            SDL2.dev
            libdrm.dev
            exiv2.dev
            libtasn1.dev
            libidn2.dev
            harfbuzz.dev
            p11-kit.dev
            glib.dev
            libsysprof-capture
            pcre2.dev
            fribidi.dev
            packages.mythffmpeg
          ];

          cmakeFlags = [
            "--preset qt5"
            "-DMYTHTV_SOURCE_VERSION_MAJOR=35"
            "-DMYTHTV_SOURCE_VERSION=35.0"
            "-DMYTHTV_SOURCE_BRANCH=master"
            "-DENABLE_NVDEC=OFF"
            "-DCMAKE_INSTALL_PREFIX=$out"
            "-DCMAKE_BUILD_TYPE=Release"
            /*
              "-DENABLE_FREETYPE=OFF"
              "-DENABLE_XML2=OFF"
              "-DENABLE_VPX=OFF"
              "-DENABLE_VDPAU=OFF"
              "-DENABLE_VAAPI=OFF"
              "-DENABLE_LIBASS=OFF"
              "-DENABLE_LIBDAV1D=OFF"
              "-DENABLE_LIBAOM=OFF"
              "-DENABLE_GNUTLS=OFF"
              "-DENABLE_FIREWIRE=OFF"
              "-DENABLE_SDL2=OFF"
              "-DENABLE_DRM=OFF"
              "-DVERBOSE=ON"
            */
          ];

          preBuild = ''
            cd /build/source/build-qt5
          '';

          #setSourceRoot = "sourceRoot=$(echo */mythtv)";
        };

        devShell = pkgs.mkShell {
          inputsFrom = [ packages.mythtv ];
        };
      }
    );
}
