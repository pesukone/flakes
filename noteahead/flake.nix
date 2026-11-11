{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    noteahead-src = {
      url = "github:juzzlin/Noteahead";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      noteahead-src,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      rec {
        packages.noteahead = pkgs.stdenv.mkDerivation {
          name = "noteahead";
          src = noteahead-src;

          nativeBuildInputs = with pkgs; [
            cmake
            pkg-config
            qt6.wrapQtAppsHook
            qt6.qttools
          ];

          buildInputs = with pkgs; [
            rtmidi
            rtaudio
            jack2
            libsndfile
            qt6.qtbase
            flac
            libogg
          ];
        };

        packages.default = packages.noteahead;
      }
    );
}
