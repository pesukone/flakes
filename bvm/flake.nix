{
  description = "bvm flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    bvm-src = {
      url = "github:Botspot/bvm";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      bvm-src,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

      in
      rec {
        packages.bvm = pkgs.stdenv.mkDerivation {
          name = "bvm";
          src = bvm-src;

          buildInputs = with pkgs; [
            bash
            jq
            wget
            cdrkit
            qemu_full
            qemu-utils
            remmina
            nmap
            yad
            seabios
            freerdp3
          ];
          nativeBuildInputs = with pkgs; [ makeWrapper ];

          dontBuild = true;
          dontConfigure = true;

          installPhase = ''
            mkdir -p $out/bin
            cp bvm $out/bin/bvm
          '';
        };

        packages.default = packages.bvm;
      }
    );
}
