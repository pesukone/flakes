{
  description = "flake for raspi utils";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    
    pinctrl-src = {
      type = "github";
      owner = "raspberrypi";
      repo = "utils";
      dir = "pinctrl";
      flake = false;
    };

    ovmerge-src = {
      type = "github";
      owner = "raspberrypi";
      repo = "utils";
      dir = "ovmerge";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    pinctrl-src,
    ovmerge-src
  }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

      in rec {
        packages.pinctrl = pkgs.stdenv.mkDerivation {
          name = "pinctrl";
	  src = pinctrl-src;

	  nativeBuildInputs = with pkgs; [ cmake ];

	  buildInputs = with pkgs; [ python3Packages.libfdt ];
	};

        packages.ovmerge = pkgs.stdenv.mkDerivation {
          name = "ovmerge";
          src = ovmerge-src;

          buildInputs = with pkgs; [ perl ];

          phases = [ "unpackPhase" "installPhase" "fixupPhase" ];

          installPhase = ''
            mkdir -p $out/bin
            cp ovmerge/ovmerge $out/bin
          '';
        };
      }
    );
}
