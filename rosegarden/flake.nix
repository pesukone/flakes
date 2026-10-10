{
  description = "rosegarden";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    rosegarden-src = {
      url = "github:tedfelix/rosegarden-official";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      rosegarden-src,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      rec {
        packages.rosegarden = pkgs.stdenv.mkDerivation {
          name = "rosegarden";
          src = rosegarden-src;

          nativeBuildInputs = with pkgs; [
            cmake
            pkg-config
            qt6.wrapQtAppsHook
            qt6.qttools
            qt6.qt5compat
          ];

          buildInputs = with pkgs; [
            qt6.qtbase
            ladspa-header
            dssi
            liblo
            lrdf
            fftwSinglePrec
            libsamplerate
            alsa-lib
            libjack2
            glib
          ];

          cmakeFlags = [
            (pkgs.lib.strings.cmakeBool "USE_QT6" true)
          ];
        };

        packages.default = packages.rosegarden;
      }
    );
}
