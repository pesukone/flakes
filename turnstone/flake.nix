{
  description = "turnstone";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    turnstone-src = {
      url = "github:turnstonelabs/turnstone";
      flake = false;
    };
    lacme-src = {
      url = "github:turnstonelabs/lacme";
      flake = false;
    };
    anthropic-src = {
      url = "github:anthropics/anthropic-sdk-python";
      flake = false;
    };
    hatchling-src = {
      url = "github:pypa/hatch?tag=hatchling-v1.26.3?dir=backend";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      turnstone-src,
      lacme-src,
      anthropic-src,
      hatchling-src,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      rec {
        packages.hatchling = pkgs.python3Packages.buildPythonPackage {
          name = "hatchling";
          version = "1.26.3";
          src = hatchling-src;
          pyproject = true;

          dependencies = with pkgs.python3Packages; [
            hatchling
            hatch-vcs
            click
            distro
            httpx2
            hyperlink
            keyring
            pexpect
            platformdirs
            pyproject-hooks
            python-discovery
            rich
            shellingham
            tomli-w
            tomlkit
            userpath
            uv
            virtualenv
          ];
        };

        packages.lacme = pkgs.python3Packages.buildPythonPackage {
          name = "lacme";
          src = lacme-src;
          pyproject = true;

          dependencies = with pkgs.python3Packages; [
            hatchling
            cryptography
            httpx
          ];
        };

        packages.anthropic = pkgs.python3Packages.buildPythonPackage {
          name = "anthropic";
          src = anthropic-src;
          pyproject = true;

          dependencies = with pkgs.python3Packages; [
            packages.hatchling
            #hatch-fancy-pypi-readme
          ];
        };

        packages.turnstone = pkgs.python3Packages.buildPythonPackage {
          name = "turnstone";
          src = turnstone-src;
          pyproject = true;

          dependencies = with pkgs.python3Packages; [
            hatchling
            alembic
            altair
            anthropic
            bcrypt
            croniter
            cryptography
            httpx-sse
            httpx
            packages.lacme
            mcp
            openai
            pillow
            psycopg
            pydantic-settings
            pydantic
            pyjwt
            pypdfium2
            python-frontmatter
            sqlalchemy
            sse-starlette
            starlette
            structlog
            uvicorn
            vl-convert-python
          ];
        };

        packages.default = packages.turnstone;
      }
    );
}
