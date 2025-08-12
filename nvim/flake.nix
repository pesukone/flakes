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

    mini-git-src = {
      url = "github:echasnovski/mini-git?ref=refs/tags/v0.16.0";
      flake = false;
    };
    mini-git-rockspec = {
      url = "https://luarocks.org/manifests/neorocks/mini.git-0.16.0-1.rockspec";
      flake = false;
    };

    mini-diff-src = {
      url = "github:echasnovski/mini.diff?ref=refs/tags/v0.16.0";
      flake = false;
    };
    mini-diff-rockspec = {
      url = "https://luarocks.org/manifests/neorocks/mini.diff-0.16.0-1.rockspec";
      flake = false;
    };

    mini-icons-src = {
      url = "github:echasnovski/mini.icons?ref=refs/tags/v0.16.0";
      flake = false;
    };
    mini-icons-rockspec = {
      url = "https://luarocks.org/manifests/neorocks/mini.icons-0.16.0-1.rockspec";
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
      mini-git-src,
      mini-git-rockspec,
      mini-diff-src,
      mini-diff-rockspec,
      mini-icons-src,
      mini-icons-rockspec,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        indentscopeRockspec = "mini.indentscope-0.16.0-1.rockspec";
        pairsRockspec = "mini.pairs-0.16.0-1.rockspec";
        gitRockspec = "mini.git-0.16.0-1.rockspec";
        diffRockspec = "mini.diff-0.16.0-1.rockspec";
        iconsRockspec = "mini.icons-0.16.0-1.rockspec";
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

        packages.mini-git = pkgs.neovimUtils.buildNeovimPlugin {
          luaAttr = pkgs.lua.pkgs.buildLuarocksPackage {
            pname = "mini.git";
            version = "0.16.0-1";
            rockspecFilename = gitRockspec;
            src = mini-git-src;

            preInstall = ''
              cp ${mini-git-rockspec} ${gitRockspec}
            '';

            disabled = pkgs.lua.pkgs.luaOlder "5.1";
          };
        };

        packages.mini-diff = pkgs.neovimUtils.buildNeovimPlugin {
          luaAttr = pkgs.lua.pkgs.buildLuarocksPackage {
            pname = "mini.diff";
            version = "0.16.0-1";
            rockspecFilename = diffRockspec;
            src = mini-diff-src;

            preInstall = ''
              cp ${mini-diff-rockspec} ${diffRockspec}
            '';

            disabled = pkgs.lua.pkgs.luaOlder "5.1";
          };
        };

        packages.mini-icons = pkgs.neovimUtils.buildNeovimPlugin {
          luaAttr = pkgs.lua.pkgs.buildLuarocksPackage {
            pname = "mini.icons";
            version = "0.16.0-1";
            rockspecFilename = iconsRockspec;
            src = mini-icons-src;

            preInstall = ''
              cp ${mini-icons-rockspec} ${iconsRockspec}
            '';

            disabled = pkgs.lua.pkgs.luaOlder "5.1";
          };
        };
      }
    );
}
