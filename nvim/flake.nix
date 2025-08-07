{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    mini-indentscope-src = {
      url = "github:echasnovski/mini.indentscope?ref=refs/tags/v0.16.0";
      flake = false;
    };
    mini-indentscope-rockspec = {
      url = "https://luarocks.org/manifests/neorocks/mini.indentscope-0.16.0-1.rockspec";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      mini-indentscope-src,
      mini-indentscope-rockspec,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        flakedPkgs = pkgs;

        packages.mini-indentscope = pkgs.lua.pkgs.buildLuarocksPackage {
          pname = "mini.indentscope";
          version = "0.16.0";
          knownRockspec = mini-indentscope-rockspec;
          src = mini-indentscope-src;

          disabled = pkgs.lua.pkgs.luaOlder "5.1";

          installPhase = ''
            ls
            exit 1
          '';
        };
      }
    );
}
