{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    u-boot-src = {
      url = "github:u-boot/u-boot?ref=refs/tags/v2026.04";
      flake = false;
    };
    rkbin-src = {
      url = "github:rockchip-linux/rkbin";
      flake = false;
    };
    optee-src = {
      url = "github:OP-TEE/optee_os";
      flake = false;
    };
    atf-src = {
      url = "github:ARM-software/arm-trusted-firmware";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      u-boot-src,
      rkbin-src,
      optee-src,
      atf-src,
    }:
    let
      /*
        aarch64-pkgs = (
          import nixpkgs {
            localSystem = "aarch64-linux";
            crossSystem = "arm-linux-gnueabihf";
            config.allowUnsupportedSystem = true;
          }
        );
      */
      aarch64-pkgs = nixpkgs.legacyPackages."aarch64-linux";
      armv7-pkgs = nixpkgs.legacyPackages."armv7l-linux";
    in
    rec {
      packages."aarch64-linux".u-boot-quartz64 = aarch64-pkgs.stdenv.mkDerivation {
        name = "u-boot-quartz64";
        src = u-boot-src;

        nativeBuildInputs = with aarch64-pkgs; [
          bison
          flex
          swig
          (python3.withPackages (
            python-pkgs: with python-pkgs; [
              setuptools
              pyelftools
            ]
          ))
        ];

        buildInputs = with aarch64-pkgs; [
          openssl.dev
          gnutls.dev
        ];

        postPatch = ''
          patchShebangs tools/binman
        '';

        preConfigure = ''
          export ROCKCHIP_TPL="$(ls ${rkbin-src}/bin/rk35/rk3566_ddr_1056MHz_v*.bin | sort | tail -n1)"
          export BL31="$(ls ${rkbin-src}/bin/rk35/rk3568_bl31_v*.elf | sort | tail -n1)"

          make quartz64-a-rk3566_defconfig
        '';

        buildPhase = ''
          make -j$(nproc)
        '';

        installPhase = ''
          cp u-boot-rockchip.bin $out
        '';
      };

      devShells."aarch64-linux".default = aarch64-pkgs.mkShell {
        inputsFrom = [ packages."aarch64-linux".u-boot-quartz64 ];
      };

      packages."armv7l-linux".u-boot-rpi2 = armv7-pkgs.stdenv.mkDerivation {
        name = "u-boot-rpi2";
        src = u-boot-src;

        nativeBuildInputs = with armv7-pkgs; [
          bison
          flex
          swig
          (python3.withPackages (
            python-pkgs: with python-pkgs; [
              setuptools
              pyelftools
            ]
          ))
        ];

        buildInputs = with armv7-pkgs; [
          openssl.dev
          gnutls.dev
        ];

        preConfigure = ''
          make rpi_2_defconfig
        '';

        buildPhase = ''
          make -j$(nproc)
        '';

        installPhase = ''
          cp u-boot.bin $out
        '';
      };

      packages."aarch64-linux".optee = aarch64-pkgs.stdenv.mkDerivation {
        name = "OP-TEE";
        src = optee-src;

        nativeBuildInputs = with aarch64-pkgs; [
          (python3.withPackages (
            python-pkgs: with python-pkgs; [
              cryptography
              pyelftools
            ]
          ))
        ];

        postPatch = ''
          patchShebangs scripts
        '';

        makeFlags = [
          "CFG_ARM64_core=y"
          "PLATFORM=rockchip"
          "PLATFORM_FLAVOR=rk3588"
        ];
      };

      packages."aarch64-linux".atf = aarch64-pkgs.stdenv.mkDerivation {
        name = "arm-trusted-firmware";
        src = atf-src;

        buildPhase = ''
          make PLAT=rk3588 bl31 -j
        '';
      };

      packages."aarch64-linux".u-boot-rk1 = aarch64-pkgs.stdenv.mkDerivation {
        name = "u-boot-rk1";
        src = u-boot-src;

        nativeBuildInputs = with aarch64-pkgs; [
          bison
          flex
          swig
          (python3.withPackages (
            python-pkgs: with python-pkgs; [
              setuptools
              pyelftools
            ]
          ))
        ];

        buildInputs = with aarch64-pkgs; [
          openssl.dev
          gnutls.dev
        ];

        postPatch = ''
          patchShebangs tools/binman
          patchShebangs scripts
        '';

        preConfigure = ''
          make ARCH=arm64 turing-rk1-rk3588_defconfig
        '';

        buildPhase = ''
          export ROCKCHIP_TPL="$(ls ${rkbin-src}/bin/rk35/rk3588_ddr_lp4_2112MHz_lp5_2400MHz_v*.bin | sort | tail -n1)"
          export BL31="$(ls ${rkbin-src}/bin/rk35/rk3588_bl31_v*.elf | sort | tail -n1)"

          ARCH=arm64 make -j$(nproc)
        '';

        installPhase = ''
          dd if=/dev/zero of=bootloader.img bs=512 count=32767
          dd if=./idbloader.img of=bootloader.img bs=512 seek=64 conv=notrunc
          dd if=./u-boot.itb of=bootloader.img bs=512 seek=16384
          cp bootloader.img $out
        '';
      };
    };
}
