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
      in
      rec {
        packages.radiance = pkgs.stdenv.mkDerivation {
          name = "radiance";
          src = radiance-src;

          nativeBuildInputs = with pkgs; [
            cmake
          ];

          cmakeFlags = [
            (pkgs.lib.strings.cmakeBool "RAD_WITH_HIP" true)
            (pkgs.lib.strings.cmakeFeature "RAD_GPU_TARGETS" "gfx1200;gfx1201")
          ];
        };

        packages.default = packages.radiance;
      }
    );
}
