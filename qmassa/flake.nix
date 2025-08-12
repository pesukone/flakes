{
  description = "qmassa flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    qmassa-src = {
      url = "github:ulissesf/qmassa";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      qmassa-src,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      rec {
        flakedPkgs = pkgs;

        packages.qmassa = pkgs.rustPlatform.buildRustPackage {
          name = "qmassa";
          src = qmassa-src;
          cargoHash = "sha256-Czr5TWtYR6tn0HqZcigCdV66nazCd44tasZ1fZpHNM0=";

          nativeBuildInputs = with pkgs; [ pkg-config ];
          buildInputs = with pkgs; [ libudev-zero ];
        };

        packages.default = packages.qmassa;
      }
    );
}
