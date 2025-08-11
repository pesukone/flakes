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
        rockspecFilename = "mini.indentscope-0.16.0-1.rockspec";
      in
      {
        flakedPkgs = pkgs;

        packages.mini-indentscope = pkgs.neovimUtils.buildNeovimPlugin {
          luaAttr = pkgs.lua.pkgs.buildLuarocksPackage {
            pname = "mini.indentscope";
            version = "0.16.0-1";
            rockspecFilename = rockspecFilename;
            src = mini-indentscope-src;

            preInstall = ''
              cp ${mini-indentscope-rockspec} ${rockspecFilename}
            '';

            disabled = pkgs.lua.pkgs.luaOlder "5.1";
          };
        };
      }
    );
}
