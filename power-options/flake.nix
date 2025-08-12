{
  description = "flake for building power-options";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    power-options-src = {
      url = "github:TheAlexDev23/power-options";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      power-options-src,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      rec {
        packages.power-options = pkgs.rustPlatform.buildRustPackage {
          name = "power-options";
          src = power-options-src;

          cargoHash = "sha256-UBVT50gRpi4a4+6Ta0q/99c4PQmNRIbCETjIMiamMYw=";

          nativeBuildInputs = with pkgs; [ pkg-config ];

          buildInputs = with pkgs; [
            glib
            gtk4
            gtk3
            libadwaita
            webkitgtk_4_1
            xdotool
          ];

          postInstall = ''
            $out/bin/power-daemon-mgr -v generate-base-files --path $out --program-path $out/bin/power-daemon-mgr

            mkdir -p $out/usr/share/icons
            mkdir -p $out/usr/share/applications
            cp -f $src/icon.png $out/usr/share/icons/power-options-gtk.png
            cp -f $src/install/power-options-gtk.desktop $out/usr/share/applications/

            #$out/bin/power-daemon-mgr setup $out
          '';
        };

        packages.default = packages.power-options;
      }
    );
}
