{
  description = "mpv flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    mpv-src = {
      type = "github";
      owner = "mpv-player";
      repo = "mpv";
      flake = false;
    };
    libplacebo-src = {
      url = "git+https://github.com/haasn/libplacebo?submodules=1";
      flake = false;
    };
    yt-dlp-src = {
      type = "github";
      owner = "yt-dlp";
      repo = "yt-dlp";
      flake = false;
    };
    wayland-protocols-src = {
      url = "git+https://gitlab.freedesktop.org/wayland/wayland-protocols.git";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    mpv-src,
    libplacebo-src,
    yt-dlp-src,
    wayland-protocols-src
  }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

      in rec {
        flakedPkgs = pkgs;

        packages.libplacebo = pkgs.stdenv.mkDerivation {
          name = "libplacebo-git";
          src = libplacebo-src;

          buildInputs = with pkgs; [
            meson
            ninja
            pkg-config
            libunwind
            shaderc
            python3Packages.glad2
            vulkan-loader
            lcms
            libdovi
            xxHash
            python3Packages.jinja2
            jinja2-cli
          ];

          mesonFlags = [
            (pkgs.lib.mesonEnable "glslang" false)
            (pkgs.lib.mesonEnable "d3d11" false)
          ];
        };

        packages.wayland-protocols = pkgs.stdenv.mkDerivation {
          name = "wayland-protocols";
          src = wayland-protocols-src;
          
          nativeBuildInputs = with pkgs; [
            meson
            ninja
            pkg-config
          ];

          buildInputs = with pkgs; [
            wayland-scanner.dev
            wayland.dev
          ];

          mesonFlags = [ "-Dtests=false" ];
        };

        packages.mpv = pkgs.stdenv.mkDerivation {
          name = "mpv";
          src = mpv-src;
          buildInputs = with pkgs; [
            pkg-config
            ffmpeg
            packages.libplacebo
            libass
            mujs
            lcms2
            libarchive
            libbluray
            rubberband
            libuchardet
            vapoursynth
            zimg
            alsa-lib
            jack2
            pipewire
            libpulseaudio
            sndio
            libcaca
            libdrm
            libsixel
            wayland
            wayland-protocols
            libxkbcommon
            xorg.libX11
            xorg.libXScrnSaver
            xorg.libXext
            xorg.libXpresent
            xorg.libXrandr
            xorg.libXv
            xorg.libXfixes
            vulkan-loader
            libva
            libvdpau
            docutils
            lua
          ];

          nativeBuildInputs = with pkgs; [ meson ninja ];

          mesonFlags = [
            (pkgs.lib.mesonEnable "lua" true)
	    (pkgs.lib.mesonEnable "wayland" false)
          ];

          postPatch = ''
            patchShebangs version.* ./TOOLS/
          '';

          mesonAutoFeatures = "auto";

          #configurePhase = ''
          #  meson setup build
          #'';
          #buildPhase = ''
          #  cd $src
          #  ls
          #  pwd
          #'';
          #installPhase = ''
          #  mkdir $out
          #'';
        };

        packages.yt-dlp = pkgs.python3Packages.buildPythonPackage {
          name = "yt-dlp";
          src = yt-dlp-src;
          format = "pyproject";

          propagatedBuildInputs = with pkgs.python3Packages; [
            hatchling
            brotli
            certifi
            mutagen
            pycryptodomex
            requests
            urllib3
            websockets
          ];
        };

        packages.default = packages.mpv;

        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            meson
          ];
        };
      }
    );
}
