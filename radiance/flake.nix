{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    radiance-src = {
      url = "git+https://codeberg.org/StillDeadCode/radiance.git";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      radiance-src,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        # A single store path with the shape of a ROCm installation (bin/, include/, lib/,
        # amdgcn/, lib/cmake/hip-lang), so radiance's CMake and ROCm's clang can treat it as
        # an ordinary ROCm root.
        rocmEnv = pkgs.symlinkJoin {
          name = "rocm-combined";
          paths = with pkgs.rocmPackages; [
            hipcc
            llvm.clang
            rocm-device-libs
            hip-common
            clr
            rocm-runtime
          ];
        };
        # hfget.sh (the model downloader, installed to libexec/radiance/) resolves jq, curl,
        # coreutils, awk, xargs, sed and a shell for its download workers from PATH; the store
        # provides none of them. Wrapping the script with a PATH that does covers the parent
        # and its workers alike.
        hfgetDeps = pkgs.symlinkJoin {
          name = "hfget-deps";
          paths = with pkgs; [
            jq
            curl
            coreutils
            gawk
            findutils
            gnused
            # bash, not dash: its bin carries `sh`, which the script's
            # `xargs ... sh hfget.sh` workers need.
            bash
          ];
        };
      in
      rec {
        packages.radiance = pkgs.stdenv.mkDerivation {
          name = "radiance";
          src = radiance-src;

          nativeBuildInputs = with pkgs; [
            cmake
          ];

          buildInputs = with pkgs; [
            jq
          ];

          # ROCm's clang (7.x / LLVM 22, what nixpkgs ships) compresses offload bundles by
          # default (fat binary magic CCOB), but the AQL backend extracts the code object
          # from the embedded fat binary itself and refuses a compressed bundle at first
          # launch: "the fat binary is a compressed offload bundle; build the kernel
          # library without --offload-compress". rad_hipify() already forces the
          # uncompressed form for kernel plugins, but not for the engine's own kernels in
          # rad_core (aql_blit.hip, advance.hip, wtab.hip, xprefetch.hip), so without this
          # patch every device dispatch fails. (Cannot be passed via cmakeFlags: a
          # multi-word -D value is word-split by the build hook.) Drop the patch once
          # upstream applies it.
          patches = [ ./radiance-core-no-offload-compress.patch ];

          cmakeFlags = [
            # A STRING cache variable upstream (ON | OFF | AUTO), not a boolean: ON makes a
            # missing hipcc a hard error instead of silently skipping the device build.
            "-DRAD_WITH_HIP=ON"
            # The offload architectures device kernels are compiled for.
            (pkgs.lib.strings.cmakeFeature "RAD_GPU_TARGETS" "gfx1200;gfx1030")
            # Satisfies find_program(RAD_HIPCC ...) without scanning /opt/rocm.
            (pkgs.lib.strings.cmakeFeature "RAD_HIPCC" "${rocmEnv}/bin/hipcc")
            # Library paths, not directories: these go on the link line as-is, and the
            # directory of RAD_HIP_RUNTIME becomes the runtime rpath.
            (pkgs.lib.strings.cmakeFeature "RAD_HIP_RUNTIME" "${rocmEnv}/lib/libamdhip64.so")
            (pkgs.lib.strings.cmakeFeature "RAD_HSA_RUNTIME" "${rocmEnv}/lib/libhsa-runtime64.so")
            # CMake's HIP language support wants ROCm's clang++; hipcc itself is refused.
            (pkgs.lib.strings.cmakeFeature "CMAKE_HIP_COMPILER" "${rocmEnv}/bin/clang++")
            # Neither clang's "Found HIP installation" probe nor hipconfig can find a ROCm
            # root in the Nix store, so point CMake at the combined env, which is where it
            # expects lib/cmake/hip-lang.
            (pkgs.lib.strings.cmakeFeature "CMAKE_HIP_COMPILER_ROCM_ROOT" "${rocmEnv}")
            # ROCm clang's default --rocm-path is /opt/rocm, which does not exist in the
            # store; without this every device compile fails with "cannot find ROCm device
            # library".
            (pkgs.lib.strings.cmakeFeature "CMAKE_HIP_FLAGS" "--rocm-path=${rocmEnv}")
            # The test suite is a device emulator that would only be compiled, never run
            # (doCheck is off), so keep the installed package lean.
            (pkgs.lib.strings.cmakeBool "RAD_BUILD_TESTS" false)
          ];

          # The engine runs hfget.sh as `sh <exe>/../libexec/radiance/hfget.sh` with the
          # server's environment, so the script's PATH is all that decides whether jq and
          # friends resolve. Replace the installed script with a wrapper that prepends
          # hfgetDeps to PATH; fixupPhase patches the wrapper's shebang.
          postInstall = ''
            real=$out/libexec/radiance/hfget.sh.real
            mv $out/libexec/radiance/hfget.sh $real
            printf '%s\n' \
              '#!/bin/sh' \
              'PATH=${hfgetDeps}/bin:$PATH' \
              'export PATH' \
              "exec $real \"\$@\"" \
              > $out/libexec/radiance/hfget.sh
            chmod +x $out/libexec/radiance/hfget.sh
          '';
        };

        packages.default = packages.radiance;
      }
    );
}
