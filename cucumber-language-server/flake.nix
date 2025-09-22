{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    cucumber-language-server-src = {
      url = "github:cucumber/language-server?ref=refs/tags/v1.7.0";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      cucumber-language-server-src,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

      in
      rec {
        packages.cucumber-language-server = pkgs.buildNpmPackage (finalAttrs: {
          pname = "cucumber-language-server";
          version = "1.7.0";

          src = cucumber-language-server-src;
          npmDepsHash = "sha256-sjoj7OLZcvFf0g/6kjhWgt/bUNKbbvYqBszNDYHxf4A=";

          npmInstallFlags = [ "--omit=optional" ];
        });

        packages.default = packages.cucumber-language-server;
      }
    );
}
