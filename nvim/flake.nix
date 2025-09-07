{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    mini-indentscope-src = {
      url = "github:nvim-mini/mini.indentscope?ref=refs/tags/v0.16.0";
      flake = false;
    };
    mini-indentscope-rockspec = {
      url = "https://luarocks.org/manifests/neorocks/mini.indentscope-0.16.0-1.rockspec";
      flake = false;
    };

    mini-pairs-src = {
      url = "github:nvim-mini/mini.pairs?ref=refs/tags/v0.16.0";
      flake = false;
    };
    mini-pairs-rockspec = {
      url = "https://luarocks.org/manifests/neorocks/mini.pairs-0.16.0-1.rockspec";
      flake = false;
    };

    mini-git-src = {
      url = "github:nvim-mini/mini-git?ref=refs/tags/v0.16.0";
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
      url = "github:nvim-mini/mini.icons?ref=refs/tags/v0.16.0";
      flake = false;
    };
    mini-icons-rockspec = {
      url = "https://luarocks.org/manifests/neorocks/mini.icons-0.16.0-1.rockspec";
      flake = false;
    };

    mini-hues-src = {
      url = "github:nvim-mini/mini.hues";
      flake = false;
    };
    mini-hues-rockspec = {
      url = "https://luarocks.org/manifests/neorocks/mini.hues-scm-1.rockspec";
      flake = false;
    };

    mini-base16-src = {
      url = "github:nvim-mini/mini.base16?ref=refs/tags/v0.16.0";
      flake = false;
    };
    mini-base16-rockspec = {
      url = "https://luarocks.org/manifests/neorocks/mini.base16-0.16.0-1.rockspec";
      flake = false;
    };

    mini-snippets-src = {
      url = "github:nvim-mini/mini.snippets?ref=refs/tags/v0.16.0";
      flake = false;
    };
    mini-snippets-rockspec = {
      url = "https://luarocks.org/manifests/neorocks/mini.snippets-0.16.0-1.rockspec";
      flake = false;
    };

    mini-completion-src = {
      url = "github:nvim-mini/mini.completion?ref=refs/tags/v0.16.0";
      flake = false;
    };
    mini-completion-rockspec = {
      url = "https://luarocks.org/manifests/neorocks/mini.completion-0.16.0-1.rockspec";
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
      mini-hues-src,
      mini-hues-rockspec,
      mini-base16-src,
      mini-base16-rockspec,
      mini-snippets-src,
      mini-snippets-rockspec,
      mini-completion-src,
      mini-completion-rockspec,
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
        huesRockspec = "mini.hues-scm-1.rockspec";
        base16Rockspec = "mini.base16-0.16.0-1.rockspec";
        snippetsRockspec = "mini.snippets-0.16.0-1.rockspec";
        completionRockspec = "mini.completion-0.16.0-1.rockspec";
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

        packages.mini-hues = pkgs.neovimUtils.buildNeovimPlugin {
          luaAttr = pkgs.lua.pkgs.buildLuarocksPackage {
            pname = "mini.hues";
            version = "scm-1";
            rockspecFilename = huesRockspec;
            src = mini-hues-src;

            preInstall = ''
              cp ${mini-hues-rockspec} ${huesRockspec}
            '';

            disabled = pkgs.lua.pkgs.luaOlder "5.1";
          };
        };

        packages.mini-base16 = pkgs.neovimUtils.buildNeovimPlugin {
          luaAttr = pkgs.lua.pkgs.buildLuarocksPackage {
            pname = "mini.base16";
            version = "0.16.0-1";
            rockspecFilename = base16Rockspec;
            src = mini-base16-src;

            preInstall = ''
              cp ${mini-base16-rockspec} ${base16Rockspec}
            '';

            disabled = pkgs.lua.pkgs.luaOlder "5.1";
          };
        };

        packages.mini-snippets = pkgs.neovimUtils.buildNeovimPlugin {
          luaAttr = pkgs.lua.pkgs.buildLuarocksPackage {
            pname = "mini.snippets";
            version = "0.16.0-1";
            rockspecFilename = snippetsRockspec;
            src = mini-snippets-src;

            preInstall = ''
              cp ${mini-snippets-rockspec} ${snippetsRockspec}
            '';

            disabled = pkgs.lua.pkgs.luaOlder "5.1";
          };
        };

        packages.mini-completion = pkgs.neovimUtils.buildNeovimPlugin {
          luaAttr = pkgs.lua.pkgs.buildLuarocksPackage {
            pname = "mini.completion";
            version = "0.16.0-1";
            rockspecFilename = completionRockspec;
            src = mini-completion-src;

            preInstall = ''
              cp ${mini-completion-rockspec} ${completionRockspec}
            '';

            disabled = pkgs.lua.pkgs.luaOlder "5.1";
          };
        };
      }
    );
}
