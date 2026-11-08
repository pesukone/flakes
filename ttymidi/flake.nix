{
  description = "ttymidi";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # The source is a Bazaar branch on Launchpad
        # (https://code.launchpad.net/~ttymidi-team/ttymidi/trunk).
        #
        # Launchpad can't be used as a URL flake input: Bazaar branches
        # have no tarball/download endpoint (only git-hosted projects
        # get one), so the branch is fetched with `bzr` (breezy) at
        # build time, pinned to a revision. The fetch needs network
        # access, which sandboxed builds don't have, so build with
        # `--option sandbox false` (the rest of the build is a single
        # gcc invocation, so running it unsandboxed is harmless).
        #
        # To update: bump `revision` to the latest revno shown at
        # https://code.launchpad.net/~ttymidi-team/ttymidi/trunk/+log
        revision = "32"; # rev-id: jari@tasankokaiku.com-20230406072042-njg4xekqm0sjxnql

        ttymidi-src = pkgs.stdenvNoCC.mkDerivation {
          name = "ttymidi-src-${revision}";
          src = null;
          dontUnpack = true;
          dontConfigure = true;
          dontBuild = true;

          nativeBuildInputs = [ pkgs.breezy ];

          installPhase = ''
            # HOME is unset in the build environment; give breezy a
            # writable home for its config/trace files.
            export HOME=$TMPDIR
            # bzr export TARGET SOURCE — fetch the pinned revision
            # directly from Launchpad and export the tree into TARGET.
            # Export flat into $out so that the build's source root is
            # the exported tree itself.
            mkdir -p $out
            bzr export \
              --revision ${revision} \
              $out \
              http://bazaar.launchpad.net/~ttymidi-team/ttymidi/trunk
          '';
        };
      in
      rec {
        flakedPkgs = pkgs;

        packages.ttymidi = pkgs.stdenv.mkDerivation {
          pname = "ttymidi";
          version = revision;
          src = ttymidi-src;

          buildInputs = with pkgs; [
            alsa-lib
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
