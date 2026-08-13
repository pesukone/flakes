{
  description = "CorsixTH";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    corsixth-src = {
      url = "github:CorsixTH/CorsixTH";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      corsixth-src,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      rec {
        packages.corsixth = pkgs.stdenv.mkDerivation {
          name = "corsix-th";
          src = corsixth-src;
          enableParallelBuilding = true;

          nativeBuildInputs = with pkgs; [
            cmake
            makeWrapper
          ];

          buildInputs = with pkgs; [
            zlib
            sdl3
            sdl3-mixer
            lua
            (lua.withPackages (
              p: with p; [
                luafilesystem
                lpeg
                luasec
                luasocket
              ]
            ))
            ffmpeg
            freetype
            curl
            rtmidi
            alsa-lib
          ];

          cmakeFlags = [
            #(pkgs.lib.strings.cmakeBool "WITH_LUAJIT" true)
          ];

          postInstall = ''
            mkdir -p $out/bin
            cp CorsixTH/corsix-th $out/bin/corsix-th
          '';

          postFixup = ''
            wrapProgram $out/bin/corsix-th \
              --set LUA_PATH "$LUA_PATH" \
              --set LUA_CPATH "$LUA_CPATH"
          '';
        };

        packages.default = packages.corsixth;
      }
    );
}
