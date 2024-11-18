{
  description = "xmrig flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    xmrig-src = {
      type = "github";
      owner = "xmrig";
      repo = "xmrig";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    xmrig-src
  }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};

      in rec {
        packages.xmrig = pkgs.stdenv.mkDerivation {
          name = "xmrig";
          src = xmrig-src;
          enableParallelBuilding = true;

          nativeBuildInputs = with pkgs; [ cmake ];
        };

        packages.default = packages.xmrig;
      }
    );
}
