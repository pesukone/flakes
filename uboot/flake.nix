{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    uboot-src = {
      url = "github:u-boot/u-boot?ref=refs/tags/v2025.07";
      flake = false;
    };
    rkbin-src = {
      url = "github:rockchip-linux/rkbin";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      uboot-src,
      rkbin-src,
    }:
    let
      aarch64-pkgs = nixpkgs.legacyPackages."aarch64-linux";
      armv7-pkgs = nixpkgs.legacyPackages."armv7l-linux";
    in
    {
      packages."aarch64-linux".uboot-quartz64 = aarch64-pkgs.stdenv.mkDerivation {
        name = "u-boot-quartz64";
        src = uboot-src;

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

        configurePhase = ''
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

      packages."armv7l-linux".uboot-rpi2 = armv7-pkgs.stdenv.mkDerivation {
        name = "u-boot-rpi2";
        src = uboot-src;
      };
    };
}
