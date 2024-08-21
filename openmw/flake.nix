{
  description = "flake for building openwm";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    openmw-src = {
      type = "github";
      owner = "OpenMW";
      repo = "openmw";
      flake = false;
    };

    bullet-src = {
      type = "github";
      owner = "bulletphysics";
      repo = "bullet3";
      flake = false;
    };

    mygui-src = {
      type = "github";
      owner = "MyGUI";
      repo = "mygui";
      flake = false;
    };

    osg-src = {
      type = "github";
      owner = "OpenMW";
      repo = "osg";
      flake = false;
    };

    collada-src = {
      type = "github";
      owner = "rdiankov";
      repo = "collada-dom";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    openmw-src,
    bullet-src,
    mygui-src,
    osg-src,
    collada-src
  }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        config = pkgs.writeTextDir "openmw.cfg" ''
          data=~/roms/morrowind/
          content=Morrowind.esm
          content=Tribunal.esm
          content=Bloodmoon.esm
          fallback-archive=Morrowind.bsa
          fallback-archive=Tribunal.bsa
          fallback-archive=Bloodmoon.bsa
        '';

      in rec {
        packages.bullet3 = pkgs.stdenv.mkDerivation {
          name = "bullet3";
          src = bullet-src;
          enableParallelBuilding = true;

          nativeBuildInputs = with pkgs; [ cmake ];

          cmakeFlags = [
            "-DBUILD_SHARED_LIBS=ON"
            "-DBUILD_CPU_DEMOS=OFF"
            "-DINSTALL_EXTRA_LIBS=ON"
            "-DOpenGL_GL_PREFERENCE=GLVND"
            "-DUSE_DOUBLE_PRECISION=ON"
            "-DBULLET2_MULTITHREADING=ON"
          ];
        };

        packages.mygui = pkgs.stdenv.mkDerivation {
          name = "mygui";
          src = mygui-src;
          enableParallelBuilding = true;

          nativeBuildInputs = with pkgs; [
            cmake
            pkg-config
            doxygen
          ];

          buildInputs = with pkgs; [
            libGL
            libGLU
            freetype.dev
            SDL2.dev
            boost
            ois
            xorg.libX11.dev
          ];

          cmakeFlags = [
            "-DMYGUI_BUILD_TOOLS=OFF"
            "-DMYGUI_BUILD_DEMOS=OFF"
            "-DMYGUI_BUILD_PLUGINS=OFF"
            "-DMYGUI_RENDERSYSTEM=4"
            "-DMYGUI_DONT_USE_OBSOLETE=ON"
          ];
        };

        packages.collada-dom = pkgs.stdenv.mkDerivation {
          name = "collada-dom";
          src = collada-src;
          enableParallelBuilding = true;

          nativeBuildInputs = with pkgs; [
            cmake
            pkg-config
          ];

          buildInputs = with pkgs; [
            boost.dev
            libxml2.dev
          ];
        };

        packages.osg-openmw = pkgs.stdenv.mkDerivation {
          name = "osg-openmw";
          src = osg-src;
          enableParallelBuilding = true;

          nativeBuildInputs = with pkgs; [
            cmake
            pkg-config
          ];

          buildInputs = with pkgs; [
            libGL.dev
            #libglvnd.dev
            xorg.libX11.dev
            #xorg.libxcb.dev
            xorg.libXdmcp
            xorg.xrandr
            xorg.libXinerama.dev
            freetype.dev
            libjpeg.dev
            jasper.dev
            zlib.dev
            gdal
            curl.dev
            SDL2.dev
            dcmtk
            poppler.dev
            cairo.dev
            librsvg.dev
            pcre2.dev
            expat.dev
            mount
            packages.collada-dom
          ];

          cmakeFlags = [
            #"-DOpenGL_GL_PREFERENCE=GLVND"
            "-DBUILD_OSG_PLUGINS_BY_DEFAULT=0"
            "-DBUILD_OSG_PLUGIN_OSG=1"
            "-DBUILD_OSG_PLUGIN_DAE=1"
            "-DBUILD_OSG_PLUGIN_DDS=1"
            "-DBUILD_OSG_PLUGIN_TGA=1"
            "-DBUILD_OSG_PLUGIN_BMP=1"
            "-DBUILD_OSG_PLUGIN_JPEG=1"
            "-DBUILD_OSG_PLUGIN_PNG=1"
            "-DBUILD_OSG_PLUGIN_FREETYPE=1"
            "-DBUILD_OSG_PLUGIN_DEPRECATED_SERIALIZERS=0"
          ];
        };

        packages.openmw = pkgs.stdenv.mkDerivation {
          name = "openmw";
          src = openmw-src;
          enableParallelBuilding = true;

          nativeBuildInputs = with pkgs; [
            cmake
            libsForQt5.qt5.wrapQtAppsHook
            pkgconf
          ];
          buildInputs = with pkgs; [
            libGL
            lz4.dev
            libsForQt5.qt5.qtbase
            libsForQt5.qt5.qttools
            yaml-cpp
            recastnavigation
            ffmpeg
            packages.bullet3
            unshield
            packages.osg-openmw
            boost.dev
            packages.mygui
            SDL2.dev
            openal
            luajit
            xorg.libXt.dev
          ];

          cmakeFlags = [
            "-DOPENMW_USE_SYSTEM_RECASTNAVIGATION=ON"
          ];
        };

        packages.default = pkgs.writeShellApplication {
          name = "launch-openmw";
          runtimeInputs = [ packages.openmw packages.osg-openmw ];

          text = ''
            openmw --data ~/roms/morrowind/ --config ${config}
          '';
        };
      }
    );
}
