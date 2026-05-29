{
  description = "asdasd";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    lycoris-lora-src = {
      url = "github:KohakuBlueleaf/LyCORIS";
      flake = false;
    };

    flash-attn-src = {
      url = "git+https://github.com/Dao-AILab/flash-attention?submodules=1";
      flake = false;
    };

    nano-vllm-src = {
      url = "github:GeeeekExplorer/nano-vllm";
      flake = false;
    };

    ace-step-src = {
      url = "github:ace-step/ACE-step-1.5";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      lycoris-lora-src,
      flash-attn-src,
      nano-vllm-src,
      ace-step-src,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pythonPackages = pkgs.python312Packages;

      in
      rec {
        packages.lycoris-lora = pythonPackages.buildPythonPackage {
          name = "lycoris-lora";
          src = lycoris-lora-src;
          pyproject = true;

          build-system = [
            pythonPackages.setuptools
          ];
          dependencies = with pythonPackages; [
            torch
            einops
            toml
            tqdm
          ];
        };

        packages.flash-attn = pythonPackages.buildPythonPackage {
          name = "flash-attn";
          src = flash-attn-src;
          pyproject = true;

          build-system = [
            pythonPackages.setuptools
          ];
          dependencies = with pythonPackages; [
            torchWithRocm
          ];
        };

        packages.nano-vllm = pythonPackages.buildPythonPackage {
          name = "nano-vllm";
          src = nano-vllm-src;
          pyproject = true;

          build-system = [
            pythonPackages.setuptools
          ];
          dependencies = with pythonPackages; [
            torch
            triton
            transformers
            flash-attn
            xxhash
          ];
        };

        packages.ace-step = pythonPackages.buildPythonPackage {
          name = "ace-step-1.5";
          src = ace-step-src;
          pyproject = true;

          build-system = [
            pythonPackages.setuptools
          ];
          dependencies = with pythonPackages; [
            hatchling
            lightning
            loguru
            packages.lycoris-lora
            matplotlib
            modelscope
            nano-vllm
            numba
            peft
            pytorch-wavelets
            pywavelets
            scipy
            soundfile
            tensorboard
            toml
            torch
            torchao
            torchaudio
            torchcodec
            torchvision
            transformers
            typer-slim
            uvicorn
            vector-quantize-pytorch
          ];
        };

        packages.default = packages.ace-step;
      }
    );
}
