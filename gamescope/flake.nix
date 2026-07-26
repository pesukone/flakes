{
  description = "gamescope";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    gamescope-src = {
      url = "git+https://github.com/ValveSoftware/gamescope?submodules=1";
      flake = false;
    };
    subproject-patch = {
      url = "file+https://github.com/ValveSoftware/gamescope/pull/1846.patch";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      gamescope-src,
      subproject-patch,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      rec {

        packages.gamescope = pkgs.stdenv.mkDerivation {
          name = "gamescope";
          src = gamescope-src;
          enableParallelBuilding = true;

          patches = [ subproject-patch ];

          nativeBuildInputs = with pkgs; [
            meson
            ninja
            pkg-config
            cmake
            wayland-scanner
            python3
          ];

          buildInputs = with pkgs; [
            pipewire
            libx11
            wayland
            wayland-protocols
            vulkan-headers
            vulkan-loader
            libxcb
            libxdamage
            libxfixes
            libxcomposite
            libxcursor
            libxrender
            libxext
            libxxf86vm
            libxtst
            libxres
            libxmu
            libxi
            libdrm
            libei
            libxkbcommon
            libcap
            SDL2
            libavif
            pixman
            udev
            lcms2
            seatd
            libinput
            xwayland
            libxcb-wm
            libxcb-errors
            hwdata
            libdecor
            glslang
            luajit
            v4l-utils
            git
            gbenchmark
            catch2_3
          ];

          mesonFlags = [
            (pkgs.lib.mesonEnable "rt_cap" true)
            (pkgs.lib.mesonEnable "drm_backend" true)
            (pkgs.lib.mesonEnable "sdl2_backend" true)

            (pkgs.lib.mesonOption "glm_include_dir" "${pkgs.lib.getInclude pkgs.glm}/include")
            (pkgs.lib.mesonOption "stb_include_dir" "${pkgs.lib.getInclude pkgs.stb}/include/stb")
          ];

          postPatch = ''
            patchShebangs .
          '';
        };

        packages.default = packages.gamescope;
      }
    );
}
