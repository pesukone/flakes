{
  description = "mythtv flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    mythtv-src = {
      type = "github";
      owner = "MythTV";
      repo = "mythtv";
      rev = "v35.0";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      mythtv-src,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

      in
      rec {
        flakedPkgs = pkgs;

        packages.mythtv = pkgs.stdenv.mkDerivation {
          name = "mythtv";
          src = mythtv-src;
        };
      }
    );
}
