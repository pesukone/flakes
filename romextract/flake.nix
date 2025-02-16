{
  description = "tools for extracting roms from steam";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    ree-pak-src = {
      type = "github";
      owner = "Ekey";
      repo = "REE.PAK.TOOL";
      flake = false;
    };

    texture2ddecoder-src = {
      type = "github";
      owner = "K0lb3";
      repo = "texture2ddecoder";
      flake = false;
    };

    etcpak-src = {
      url = "git+https://github.com/K0lb3/etcpak?submodules=1";
      flake = false;
    };

    astc-encoder-py-src = {
      url = "git+https://github.com/K0lb3/astc-encoder-py?submodules=1";
      flake = false;
    };

    pyfmodex-src = {
      type = "github";
      owner = "tyrylu";
      repo = "pyfmodex";
      flake = false;
    };

    unitypy-src = {
      type = "github";
      owner = "K0lb3";
      repo = "UnityPy";
      flake = false;
    };

    extract-toolbox-src = {
      type = "github";
      owner = "shawngmc";
      repo = "game-extraction-toolbox";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ree-pak-src,
    texture2ddecoder-src,
    etcpak-src,
    astc-encoder-py-src,
    pyfmodex-src,
    unitypy-src,
    extract-toolbox-src
  }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
	pythonPackages = pkgs.python311Packages;

      in rec {
        packages.ree-unpacker = pkgs.buildDotnetModule {
	  name = "ree-unpack";
	  src = ree-pak-src;

	  buildInputs = [ pkgs.mono4 ];

	  projectFile = "REE.Unpacker/REE.Unpacker/REE.Unpacker.csproj";
	};

	packages.texture2ddecoder = pythonPackages.buildPythonPackage {
	  name = "texture2ddecoder";
	  src = texture2ddecoder-src;
	};

	packages.etcpak = pythonPackages.buildPythonPackage {
	  name = "etcpak";
	  src = etcpak-src;

	  dependencies = with pythonPackages; [
	    archspec
	  ];
	};

	packages.astc-encoder-py = pythonPackages.buildPythonPackage {
	  name = "astc-encoder-py";
	  src = astc-encoder-py-src;

	  dependencies = with pythonPackages; [
	    archspec
	  ];
	};

	packages.pyfmodex = pythonPackages.buildPythonPackage {
	  name = "pyfmodex";
	  src = pyfmodex-src;
	  pyproject = true;
	  
	  dependencies = with pythonPackages; [
	    poetry-core
	  ];
	};

	packages.unitypy = pythonPackages.buildPythonPackage {
	  name = "unitypy";
	  src = unitypy-src;
	  pyproject = true;

	  build-system = [
	    pythonPackages.setuptools
	  ];
	  dependencies = with pythonPackages; [
	    lz4
	    brotli
	    pillow
	    packages.texture2ddecoder
	    packages.etcpak
	    packages.astc-encoder-py
	    packages.pyfmodex
	    fsspec
	    attrs
	  ];
	};

	packages.game-extraction-toolbox = pythonPackages.buildPythonPackage {
	  name = "game-extraction-toolbox";
	  src = extract-toolbox-src;
	  pyproject = true;

	  build-system = [
	    pythonPackages.setuptools
	  ];
	  dependencies = with pythonPackages; [
	    bitarray
	    click
	    click-log
	    psutil
	    rich
	    texttable
	    packages.unitypy
	    magic
	    setuptools
	  ];
	};

	devShell = pkgs.mkShell {
	  buildInputs = [ packages.game-extraction-toolbox ];
	};
      }
    );
}
