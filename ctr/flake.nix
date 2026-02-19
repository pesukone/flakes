{
  description = "flake for building psycross";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";

    ctr-sdk.url = "git+https://github.com/CTR-tools/CTR-ModSDK?submodules=1";
  };

  outputs =
    {
      self,
      flake-utils,
      ctr-sdk,
    }:
    flake-utils.lib.eachDefaultSystem (system: rec {
      packages.ctr-pc = ctr-sdk.packages.${system}.pc-decomp.release.native32.gcc.overrideAttrs {
        postPatch = ''
          substituteInPlace ../rebuild_PS1/TEST_226.c \
          --replace-fail "*(unsigned char*)&tlByteAddr[tlU3 + 0], *(unsigned char*)&tlByteAddr[tlU3 + 1]," "*(unsigned char*)&tlByteAddr[tlU3 + 0], *(unsigned char*)&tlByteAddr[tlU3 + 1]"
        '';

      };

      packages.default = packages.ctr-pc;
    });
}
