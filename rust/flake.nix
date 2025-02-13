{
  description = "rust flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    coc-rust-analyzer-src = {
      url = "github:fannheyward/coc-rust-analyzer";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    coc-rust-analyzer-src
  }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};

      in rec {
        flakedPkgs = pkgs;

        packages.coc-rust-analyzer = pkgs.buildNpmPackage {
          name = "coc-rust-analyzer";
          src = coc-rust-analyzer-src;

          npmDepsHash = "sha256-u3BLBHybSMoL+JRsJXeeBGKHqWHoFpVmwf3K/6tszXQ=";
        };
      }
    );
}
