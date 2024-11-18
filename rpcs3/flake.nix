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

          nativeBuildInputs = with pkgs; [ cmake ];
        };

        packages.default = packages.rpcs3;
      }
    );
}
