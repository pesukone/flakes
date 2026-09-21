{
  description = "turnstone";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    turnstone-src = {
      url = "github:turnstonelabs/turnstone/main";
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
      url = "git+https://github.com/openai/openai-python?ref=refs/tags/v3.6.0";
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
            httpx2
            idna
          ];
        };

        packages.anthropic = pkgs.python3Packages.buildPythonPackage {
          pname = "anthropic";
          version = "0.121.0";
          pyproject = true;
          src = anthropic-src;
          postPatch = "sed -i 's/hatchling==1.26.3/hatchling>=1.26.3/' pyproject.toml";

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
          version = "3.6.0";
          pyproject = true;
          src = openai-src;
          postPatch = "sed -i 's/hatchling==1.27.0/hatchling>=1.27.0/' pyproject.toml; sed -i 's/httpx2>=2.7.0/httpx2>=2.0.0/' pyproject.toml; sed -i 's/jiter>=0.16.0/jiter>=0.12.0/' pyproject.toml";

          build-system = with pkgs.python3Packages; [
            hatchling
            hatch-fancy-pypi-readme
          ];

          dependencies = with pkgs.python3Packages; [
            anyio
            distro
            httpx
            httpx2
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
          postPatch = "sed -i 's/pydantic-settings>=2.14.2/pydantic-settings>=2.12.0/' pyproject.toml; sed -i 's/httpx2>=2.12,<3/httpx2>=2.0,<3/' pyproject.toml";

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
            httpx2
            idna
          ];
        };

        packages.default = packages.turnstone;
      }
    );
}
