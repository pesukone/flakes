{
  description = "openxray flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    openxray-src = {
      url = "git+https://github.com/OpenXRay/xray-16?submodules=1";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    openxray-src
  }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};

      in rec {
        packages.openxray = pkgs.stdenv.mkDerivation {
          name = "openxray";
          src = openxray-src;
          enableParallelBuilding = true;

          nativeBuildInputs = with pkgs; [ cmake ];

          buildInputs = with pkgs; [
            SDL2.dev
            openal
            libogg.dev
            libvorbis.dev
            libtheora.dev
            lzo
            mimalloc.dev
            libjpeg.dev
            libglvnd.dev
          ];

          postInstall = ''
            mv $out/bin/xr_3da $out/bin/openxray
          '';
        };

        packages.default = packages.openxray;
      }
    );
}
