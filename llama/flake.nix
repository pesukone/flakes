{
  description = "llama.cpp flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    llama-src = {
      url = "github:ggml-org/llama.cpp";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      llama-src,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

      in
      rec {
        packages.llama = pkgs.stdenv.mkDerivation {
          name = "llama.cpp";
          src = llama-src;
          enableParallelBuilding = true;

          nativeBuildInputs = with pkgs; [
            cmake
            pkg-config
          ];

          buildInputs = with pkgs; [
            rocmPackages.clr
            rocmPackages.rocblas
            rocmPackages.hipblas
            #rocmPackages.rocwmma
            openblas
            vulkan-headers
            vulkan-loader
            shaderc
            openvino
            onetbb
          ];

          cmakeFlags = [
            (pkgs.lib.strings.cmakeFeature "CMAKE_BUILD_TYPE" "Release")
            (pkgs.lib.strings.cmakeBool "GGML_NATIVE" false)
            (pkgs.lib.strings.cmakeBool "LLAMA_BUILD_EXAMPLES" false)
            (pkgs.lib.strings.cmakeBool "LLAMA_BUILD_SERVER" true)
            (pkgs.lib.strings.cmakeBool "LLAMA_BUILD_TESTS" false)
            (pkgs.lib.strings.cmakeBool "LLAMA_BUILD_OPENSSL" true)
            (pkgs.lib.strings.cmakeBool "GGML_BLAS" true)
            (pkgs.lib.strings.cmakeBool "GGML_HIP" true)
            #(pkgs.lib.strings.cmakeBool "GGML_HIP_ROCWMMA_FATTN" true)
            (pkgs.lib.strings.cmakeBool "GGML_RPC" true)
            (pkgs.lib.strings.cmakeBool "GGML_VULKAN" true)
            (pkgs.lib.strings.cmakeBool "GGML_BACKEND_DL" true)
            (pkgs.lib.strings.cmakeBool "GGML_OPENVINO" true)
            (pkgs.lib.strings.cmakeFeature "CMAKE_HIP_COMPILER" "${pkgs.rocmPackages.llvm.clang}/bin/clang")
            (pkgs.lib.strings.cmakeFeature "CMAKE_HIP_ARCHITECTURES" "gfx1201;gfx1030")
          ];

          env = {
            ROCM_PATH = "${pkgs.rocmPackages.clr}";
            HIP_DEVICE_LIB_PATH = "${pkgs.rocmPackages.rocm-device-libs}/amdgcn/bitcode";
            INTEL_OPENVINO_DIR = "${pkgs.openvino}";
            OpenVINO_DIR = "${pkgs.openvino}/runtime/cmake";
          };
        };

        packages.default = packages.llama;
      }
    );
}
