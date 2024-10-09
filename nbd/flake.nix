{
  description = "flake for building nbd client and server";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    nbd-src = {
      type = "github";
      owner = "NetworkBlockDevice";
      repo = "nbd";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, nbd-src }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};

      in rec {
        flakedPkgs = pkgs;

	packages.nbd = pkgs.stdenv.mkDerivation {
          name = "nbd";
          src = nbd-src;

	  nativeBuildInputs = with pkgs; [
            pkg-config
	    flex
            bison
	    #git
	    autoconf-archive
	    autoreconfHook
          ];

	  buildInputs = with pkgs; [
	    glib
	    gnutls
	    libnl
	    linuxHeaders
	  ];

	  configureFlags = [
	    "--sysconfdir=/etc"
	    "--enable-debug"
	  ];
        };

	packages.default = packages.nbd;
      }
    );
}
