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

    mini-pairs-src = {
      url = "github:echasnovski/mini.pairs?ref=refs/tags/v0.16.0";
      flake = false;
    };
    mini-pairs-rockspec = {
      url = "https://luarocks.org/manifests/neorocks/mini.pairs-0.16.0-1.rockspec";
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
      mini-pairs-src,
      mini-pairs-rockspec,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        indentscopeRockspec = "mini.indentscope-0.16.0-1.rockspec";
        pairsRockspec = "mini.pairs-0.16.0-1.rockspec";
      in
      {
        flakedPkgs = pkgs;

        packages.mini-indentscope = pkgs.neovimUtils.buildNeovimPlugin {
          luaAttr = pkgs.lua.pkgs.buildLuarocksPackage {
            pname = "mini.indentscope";
            version = "0.16.0-1";
            rockspecFilename = indentscopeRockspec;
            src = mini-indentscope-src;

            preInstall = ''
              cp ${mini-indentscope-rockspec} ${indentscopeRockspec}
            '';

            disabled = pkgs.lua.pkgs.luaOlder "5.1";
          };
        };

        packages.mini-pairs = pkgs.neovimUtils.buildNeovimPlugin {
          luaAttr = pkgs.lua.pkgs.buildLuarocksPackage {
            pname = "mini.pairs";
            version = "0.16.0-1";
            rockspecFilename = pairsRockspec;
            src = mini-pairs-src;

            preInstall = ''
              cp ${mini-pairs-rockspec} ${pairsRockspec}
            '';

            disabled = pkgs.lua.pkgs.luaOlder "5.1";
          };
        };
      }
    );
}
