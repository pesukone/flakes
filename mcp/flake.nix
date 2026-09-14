{
  description = "mcp servers";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    postgres-mcp-src = {
      url = "github:crystaldba/postgres-mcp";
      flake = false;
    };

    chrome-devtools-mcp-src = {
      url = "git+https://github.com/ChromeDevTools/chrome-devtools-mcp?submodules=1";
      flake = false;
    };

    comfy-mcp-src = {
      url = "github:Comfy-Org/comfy-mcp";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      postgres-mcp-src,
      chrome-devtools-mcp-src,
      comfy-mcp-src,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.postgres-mcp = pkgs.python3Packages.buildPythonPackage {
          name = "postgres-mcp";
          src = postgres-mcp-src;
          pyproject = true;

          nativeBuildInputs = with pkgs.python3Packages; [
            hatchling
          ];

          dependencies = with pkgs.python3Packages; [
            attrs
            humanize
            instructor
            mcp
            pglast
            psycopg-pool
            psycopg
          ];
        };

        packages.chrome-devtools-mcp = pkgs.buildNpmPackage (finalAttrs: {
          name = "chrome-devtools-mcp";
          src = chrome-devtools-mcp-src;

          npmDepsHash = "sha256-eYydcdidC990mFIdUNXqKoYpnuDhX3+dCaAE5GHyF3M=";
        });

        packages.comfy-mcp = pkgs.python3Packages.buildPythonPackage {
          name = "comfy-mcp";
          src = comfy-mcp-src;
          pyproject = true;
        };
      }
    );
}
