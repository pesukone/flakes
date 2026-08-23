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
    openai-src = {
      url = "github:openai/openai-python";
      flake = false;
    };
    pydantic-settings-src = {
      url = "github:pydantic/pydantic-settings";
      flake = false;
    };
    hatchling-src = {
      url = "github:pypa/hatch?tag=hatchling-v1.26.3&dir=backend";
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
      openai-src,
      pydantic-settings-src,
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
            packaging
            pathspec
            pluggy
            tomlkit
            trove-classifiers
          ];
        };

        packages.lacme = pkgs.python3Packages.buildPythonPackage {
          name = "lacme";
          src = lacme-src;
          pyproject = true;

          build-system = [ packages.hatchling ];

          dependencies = with pkgs.python3Packages; [
            cryptography
            httpx2
          ];
        };

        packages.anthropic = pkgs.python3Packages.buildPythonPackage {
          name = "anthropic";
          src = anthropic-src;
          pyproject = true;

          build-system = [
            packages.hatchling
            (pkgs.python3Packages.hatch-fancy-pypi-readme.overridePythonAttrs (old: {
              propagatedBuildInputs = [ packages.hatchling ];
            }))
          ];

          dependencies = with pkgs.python3Packages; [
            httpx
            pydantic
            typing-extensions
            anyio
            sniffio
            jiter
            docstring-parser
          ];
        };

        packages.openai = pkgs.python3Packages.buildPythonPackage {
          name = "openai";
          src = openai-src;
          pyproject = true;

          build-system = [
            packages.hatchling
          ];

          dependencies = with pkgs.python3Packages; [
            httpx2
            pydantic
            typing-extensions
            anyio
            distro
            sniffio
            tqdm
            jiter
          ];
        };

        packages.pydantic-settings = pkgs.python3Packages.buildPythonPackage {
          name = "pydantic-settings";
          src = pydantic-settings-src;
          pyproject = true;

          build-system = [ pkgs.python3Packages.hatchling ];

          dependencies = with pkgs.python3Packages; [
            pydantic
            python-dotenv
            typing-inspection
          ];
        };

        packages.turnstone = pkgs.python3Packages.buildPythonPackage {
          name = "turnstone";
          src = turnstone-src;
          pyproject = true;

          build-system = [ pkgs.python3Packages.hatchling ];

          dependencies =
            with pkgs.python3Packages;
            [
              alembic
              altair
              bcrypt
              croniter
              cryptography
              httpx-sse
              httpx
              mcp
              pillow
              psycopg
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
            ]
            ++ [
              packages.anthropic
              packages.lacme
              packages.openai
              packages.pydantic-settings
            ];
        };

        packages.default = packages.turnstone;
      }
    );
}
