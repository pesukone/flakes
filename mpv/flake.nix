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
  };

  outputs = { self, nixpkgs, flake-utils, mpv-src, libplacebo-src }:
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

        packages.default = pkgs.stdenv.mkDerivation {
          name = "mpv-git";
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

        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            meson
          ];
        };
      }
    );
}
