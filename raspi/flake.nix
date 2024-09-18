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
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    pinctrl-src
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
      }
    );
}
