{
  description = "flake for building kodi";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    groovy-zip = {
      url = "http://mirrors.kodi.tv/build-deps/sources/apache-groovy-binary-4.0.16.zip";
      flake = false;
    };
    apache-commons-lang-zip = {
      url = "http://mirrors.kodi.tv/build-deps/sources/commons-lang3-3.14.0-bin.tar.gz";
      flake = false;
    };
    apache-commons-text-zip = {
      url = "http://mirrors.kodi.tv/build-deps/sources/commons-text-1.11.0-bin.tar.gz";
      flake = false;
    };

    libdvdcss-src = {
      type = "github";
      owner = "xbmc";
      repo = "libdvdcss";
      ref = "1.4.3-Next-Nexus-Alpha2-2";
      flake = false;
    };
    libdvdread-src = {
      type = "github";
      owner = "xbmc";
      repo = "libdvdread";
      ref = "6.1.3-Next-Nexus-Alpha2-2";
      flake = false;
    };
    libdvdnav-src = {
      type = "github";
      owner = "xbmc";
      repo = "libdvdnav";
      ref = "6.1.1-Next-Nexus-Alpha2-2";
      flake = false;
    };

    x265-src = {
      url = "git+https://bitbucket.org/multicoreware/x265_git";
      flake = false;
    };

    ffmpeg-src = {
      type = "github";
      owner = "FFmpeg";
      repo = "FFmpeg";
      ref = "release/6.1";
      flake = false;
    };

    kodi-src = {
      type = "github";
      owner = "xbmc";
      repo = "xbmc";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    groovy-zip,
    apache-commons-lang-zip,
    apache-commons-text-zip,
    libdvdcss-src,
    libdvdread-src,
    libdvdnav-src,
    x265-src,
    ffmpeg-src,
    kodi-src
  }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        enableFeature = pkgs.lib.enableFeature;

      in rec {
        flakedPkgs = pkgs;

        packages.x265 = pkgs.stdenv.mkDerivation {
          name = "x265";
          src = x265-src;
          enableParallelBuilding = true;

          nativeBuildInputs = with pkgs; [
            cmake
            nasm
            numactl
          ];

          cmakeFlags = [
            "-DNATIVE_BUILD=ON"
          ];

          preConfigure = ''
            cd source
          '';
        };

        packages.ffmpeg = pkgs.stdenv.mkDerivation {
          name = "ffmpeg";
          src = ffmpeg-src;
          enableParallelBuilding = true;

          nativeBuildInputs = with pkgs; [
            yasm
            pkg-config
          ];

          buildInputs = with pkgs; [
            libv4l
            x264
            x265
            libva1
            libpulseaudio
            lame
            libvpx
            dav1d
            fdk_aac
          ];

          configureFlags = [
            (enableFeature true "shared")
            (enableFeature true "nonfree")
            (enableFeature true "gpl")
            (enableFeature true "pthreads")
            (enableFeature true "ffmpeg")
            (enableFeature true "ffplay")
            (enableFeature true "ffprobe")
            (enableFeature true "avcodec")
            (enableFeature true "avdevice")
            (enableFeature true "avfilter")
            (enableFeature true "avformat")
            (enableFeature true "avutil")
            (enableFeature true "swresample")
            (enableFeature true "swscale")
            (enableFeature true "libv4l2")
            (enableFeature true "v4l2-m2m")
            (enableFeature false "vaapi")
            (enableFeature true "libx264")
            (enableFeature true "libx265")
            (enableFeature true "libdav1d")
            (enableFeature true "libpulse")
            (enableFeature true "libmp3lame")
            (enableFeature true "libfdk-aac")
            (enableFeature true "libvpx")
            (enableFeature true "optimizations")
          ];
        };

        packages.kodi = pkgs.stdenv.mkDerivation {
          name = "kodi";
          src = kodi-src;
          enableParallelBuilding = true;

          nativeBuildInputs = with pkgs; [
            cmake
            pkg-config
            autoconf
            automake
            libtool
            doxygen
            jre_headless
          ];

          buildInputs = with pkgs; [
            crossguid
            fmt
            spdlog.dev
            waylandpp.dev
            kdePackages.wayland-protocols
            lzo
            libpng
            giflib
            libjpeg.dev
            python3
            libxml2.dev
            libass.dev
            libcdio
            libuuid.dev
            curl.dev
            exiv2.dev
            flatbuffers
            freetype.dev
            fribidi.dev
            fstrcmp.dev
            harfbuzz.dev
            pcre2.dev
            rapidjson
            sqlite.dev
            kdePackages.taglib
            tinyxml
            tinyxml-2
            libdrm.dev
            libxkbcommon.dev
            swig4
            libcec
            fontconfig.dev
            #packages.ffmpeg
            ffmpeg.dev
            glib.dev
            gtest.dev
            libGL.dev
            kdePackages.wayland.dev
            mesa
            dbus
            libnfs
            libpulseaudio
          ];

          cmakeFlags = [
            "-DCORE_PLATFORM_NAME=wayland"
            "-DAPP_RENDER_SYSTEM=gles"

            "-DENABLE_INTERNAL_CROSSGUID=off"
            "-DENABLE_INTERNAL_FFMPEG=off"
            "-DENABLE_INTERNAL_CEC=off"
            "-DENABLE_INTERNAL_CURL=off"
            "-DENABLE_INTERNAL_EXIV2=off"
            "-DENABLE_INTERNAL_FLATBUFFERS=off"
            "-DENABLE_INTERNAL_FMT=off"
            "-DENABLE_INTERNAL_NFS=off"
            "-DENABLE_INTERNAL_PCRE2=off"
            "-DENABLE_INTERNAL_RapidJSON=off"

            "-Dgroovy_SOURCE_DIR=${groovy-zip}"
            "-Dapache-commons-lang_SOURCE_DIR=${apache-commons-lang-zip}"
            "-Dapache-commons-text_SOURCE_DIR=${apache-commons-text-zip}"

            "-Dlibdvdcss_URL=${libdvdcss-src}"
            "-Dlibdvdread_URL=${libdvdread-src}"
            "-Dlibdvdnav_URL=${libdvdnav-src}"
          ];
        };

        packages.default = packages.kodi;
      }
    );
}
