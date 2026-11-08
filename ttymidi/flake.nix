{
  description = "ttymidi";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    ttymidi-src = {
      url = "https://varal.org/ttymidi/ttymidi.tar.gz";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ttymidi-src,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      rec {
        flakedPkgs = pkgs;

        packages.ttymidi = pkgs.stdenv.mkDerivation {
          name = "ttymidi";
          src = ttymidi-src;

          buildInputs = with pkgs; [
            alsa-lib
          ];

          NIX_CFLAGS_COMPILE = [
            "-Wno-implicit-int"
          ];

          # Upstream Makefile: gcc src/ttymidi.c -o ttymidi -lasound -lpthread
          buildPhase = "make";

          installPhase = ''
            install -Dm755 ttymidi $out/bin/ttymidi
          '';
        };

        packages.default = packages.ttymidi;
      }
    );
}
