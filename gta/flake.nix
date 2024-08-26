{
  description = "flake for gta3 and vice city";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    librw-src = {
      type = "github";
      owner = "aap";
      repo = "librw";
      flake = false;
    };

    /*
    gta3-src = {
      type = "github";
      owner = "halpz";
      repo = "re3";
      flake = false;
    };
    */
    gta3-src = {
      url = "git+https://github.com/halpz/re3?submodules=1";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    librw-src,
    gta3-src
  }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

      in rec {
        packages.gta3-bin = pkgs.multiStdenv.mkDerivation {
          name = "gta3-bin";
          src = gta3-src;
          enableParallelBuilding = true;

          nativeBuildInputs = with pkgs; [
            premake5
            gnumake
          ];

          buildInputs = with pkgs; [
            glfw
            openal
            libmpg123
            libsndfile
          ];

          postPatch = ''
            patchShebangs printHash.sh
          '';

          configurePhase = ''
            premake5 --with-librw --no-git-hash gmake2
          '';

          buildPhase = ''
            cd build
            make config=release_linux-amd64-librw_gl3_glfw-oal -j$(nproc)
          '';

          installPhase = ''
            mkdir -p $out/bin
            cp ../bin/linux-amd64-librw_gl3_glfw-oal/Release/re3 $out/bin/gta3
          '';
        };

        packages.gta3-assets = pkgs.stdenv.mkDerivation {
          name = "gta3-assets";
          src = gta3-src;

          phases = [ "unpackPhase" "installPhase" ];

          installPhase = ''
            mkdir $out
            cp -r gamefiles/* $out
          '';
        };

        packages.gta3 = pkgs.writeShellApplication {
          name = "gta3";
          runtimeInputs = [ packages.gta3-bin packages.gta3-assets ];

          text = ''
            cd ~/roms/gta3
            cp ${packages.gta3-bin}/bin/gta3 ./gta3
            cp -r ${packages.gta3-assets}/* .

            chmod -R u+w ./*

            ./gta3
          '';
        };
      }
    );
}
