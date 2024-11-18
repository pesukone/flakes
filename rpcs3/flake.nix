{
  description = "rpcs3 flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    rpcs3-src = {
      url = "git+https://github.com/RPCS3/rpcs3?submodules=1";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    rpcs3-src
  }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};

      in rec {
        packages.rpcs3 = pkgs.stdenv.mkDerivation {
          name = "rpcs3";
          src = rpcs3-src;
          enableParallelBuilding = true;

          nativeBuildInputs = with pkgs; [
            cmake
            pkg-config
          ];

          buildInputs = with pkgs; [
            zlib.dev
            glew.dev
            libudev-zero
            openal
            ffmpeg.dev
            llvm.dev
            curl.dev
            qt6.full
            wayland.dev
            xorg.libX11.dev
            vulkan-headers
            vulkan-validation-layers
            SDL2.dev
            sndio
            pulseaudio.dev
          ];

          cmakeFlags = [
            "-DUSE_SYSTEM_FFMPEG=ON"
          ];
        };

        packages.default = packages.rpcs3;
      }
    );
}
