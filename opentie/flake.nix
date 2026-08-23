{
  description = "OpenTIE";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    opentie-src = {
      url = "git+https://github.com/elyosh/OpenTIE?submodules=1";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      opentie-src,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      rec {
        packages.opentie = pkgs.stdenv.mkDerivation {
          name = "opentie";
          src = opentie-src;
          enableParallelBuilding = true;

          nativeBuildInputs = with pkgs; [ cmake ];
        };

        packages.default = packages.opentie;
      }
    );
}
