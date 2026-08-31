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
      url = "git+https://github.com/anthropics/anthropic-sdk-python?ref=refs/tags/v0.121.0";
      flake = false;
    };
    openai-src = {
      url = "git+https://github.com/openai/openai-python?ref=refs/tags/v2.53.0";
      flake = false;
    };
    pydantic-settings-src = {
      url = "git+https://github.com/pydantic/pydantic-settings?ref=refs/tags/v2.15.0";
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
      openai-src,
      pydantic-settings-src,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      rec {
        packages.lacme = pkgs.python3Packages.buildPythonPackage {
          name = "lacme";
          src = lacme-src;
          pyproject = true;

          nativeBuildInputs = with pkgs.python3Packages; [
            hatchling
          ];

          dependencies = with pkgs.python3Packages; [
            cryptography
            httpx
          ];
        };

        packages.anthropic = pkgs.python3Packages.buildPythonPackage {
          pname = "anthropic";
          version = "0.121.0";
          pyproject = true;
          src = anthropic-src;

          postPatch = ''
            substituteInPlace pyproject.toml \
              --replace-fail '"hatchling==1.26.3"' '"hatchling"'
          '';

          build-system = with pkgs.python3Packages; [
            hatchling
            hatch-fancy-pypi-readme
          ];

          dependencies = with pkgs.python3Packages; [
            anyio
            distro
            docstring-parser
            httpx
            jiter
            pydantic
            sniffio
            typing-extensions
          ];
        };

        packages.openai = pkgs.python3Packages.buildPythonPackage {
          pname = "openai";
          version = "2.53.0";
          pyproject = true;
          src = openai-src;

          postPatch = ''
            substituteInPlace pyproject.toml \
              --replace-fail '"hatchling==1.26.3"' '"hatchling"'
          '';

          build-system = with pkgs.python3Packages; [
            hatchling
            hatch-fancy-pypi-readme
          ];

          dependencies = with pkgs.python3Packages; [
            anyio
            distro
            httpx
            jiter
            pydantic
            sniffio
            tqdm
            typing-extensions
          ];
        };

        packages.pydantic-settings = pkgs.python3Packages.buildPythonPackage {
          pname = "pydantic-settings";
          version = "2.15.0";
          pyproject = true;
          src = pydantic-settings-src;

          build-system = with pkgs.python3Packages; [ hatchling ];

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

          doCheck = false;

          build-system = with pkgs.python3Packages; [ hatchling ];

          dependencies = with pkgs.python3Packages; [
            alembic
            altair
            packages.anthropic
            bcrypt
            croniter
            cryptography
            httpx-sse
            httpx
            packages.lacme
            mcp
            packages.openai
            pillow
            psycopg
            packages.pydantic-settings
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
