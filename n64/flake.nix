{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    ghostship-src = {
      url = "git+https://github.com/HarbourMasters/Ghostship?submodules=1";
      flake = false;
    };

    shipwright-src = {
      url = "git+https://github.com/HarbourMasters/Shipwright?submodules=1";
      flake = false;
    };

    harkinian2-src = {
      url = "git+https://github.com/HarbourMasters/2ship2harkinian?submodules=1";
      flake = false;
    };

    starship-src = {
      url = "git+https://github.com/HarbourMasters/Starship?submodules=1";
      flake = false;
    };

    dr-libs-src = {
      url = "git+https://github.com/mackron/dr_libs?submodules=1&ref=da35f9d6c7374a95353fd1df1d394d44ab66cf01";
      flake = false;
    };

    spaghettikart-src = {
      url = "git+https://github.com/HarbourMasters/SpaghettiKart?submodules=1";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ghostship-src,
      shipwright-src,
      harkinian2-src,
      starship-src,
      dr-libs-src,
      spaghettikart-src,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

      in
      {
        packages.dr-libs = pkgs.stdenv.mkDerivation {
          name = "dr_libs";
          src = dr-libs-src;

          nativeBuildInputs = with pkgs; [ cmake ];
          buildInputs = with pkgs; [ libsndfile ];

          cmakeFlags = [
            "-DDR_LIBS_BUILD_TESTS=ON"
          ];

          installPhase = ''
            cp mp3_extract mp3_basic mp3_playback $out/bin
            ls
            exit 1
          '';
        };

        packages.mk64 = pkgs.stdenv.mkDerivation {
          name = "spaghettikart";
          src = spaghettikart-src;
          enableParallelBuilding = true;

          nativeBuildInputs = with pkgs; [ cmake ];

          buildInputs = with pkgs; [ libGL ];
        };
      }
    );
}
