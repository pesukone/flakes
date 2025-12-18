{
  description = "Build image";
  inputs.nixpkgs.url = "github:nixos/nixpkgs";

  outputs =
    { self, nixpkgs }:
    rec {
      nixosConfigurations.rpi2 = nixpkgs.lib.nixosSystem {
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-base.nix"
          {
            nixpkgs.config.allowUnsupportedSystem = true;
            nixpkgs.config.allowBroken = true;
            nixpkgs.hostPlatform.system = "armv7l-linux";
            #nixpkgs.buildPlatform.system = "x86_64-linux";
          }
        ];
      };

      images.rpi2 = nixosConfigurations.rpi2.config.system.build.isoImage;
    };
}
