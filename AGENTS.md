# AGENTS.md

This is a personal collection of **independent Nix flakes** (one per subdirectory).
There is no top-level `flake.nix`, no README, no CI, and no lint/test tooling.
Each `<name>/flake.nix` + `<name>/flake.lock` is self-contained; treat them as
separate projects.

## Conventions

- Flakes share a recurring template: `nixpkgs.url = "github:nixos/nixpkgs"` +
  `flake-utils.url = "github:numtide/flake-utils"`, sources declared with
  `flake = false`, outputs via `flake-utils.lib.eachDefaultSystem`, `pkgs =
  nixpkgs.legacyPackages.${system}`, and `packages.default = packages.<name>`.
  Follow this style in edits.
- Exceptions that diverge from the template:
  - `install-iso` is a **NixOS system config** (`nixosConfigurations`/`images.rpi2`),
    not a package flake — builds with `nix build .#images.rpi2`.
  - `uboot` does not use `flake-utils`; it produces a firmware binary
    (`uboot/u-boot-rk1.bin`).
- Sources using `url = "git+https://...?submodules=1"` need submodules (13 flakes:
  ace-step, ctr, dolphin, gamescope, gta, keeperfx, mpv, n64, openxray,
  romextract, rpcs3, rust, snes9x).
- Only `sm` references local files via `${self}` (`${self}/sm.ini`, `${self}`
  outputs); the directory is the flake root.
- Three flakes use `pkgs.rustPlatform.buildRustPackage` (power-options, qmassa,
  rust) — require `cargoHash`.

## Commands

From inside a subdirectory:

```
nix build .#<package-name>      # builds; creates gitignored `result` symlink
nix build .#packages.default    # builds the default package
nix develop                     # shell if a devShell is defined (llama, mpv,
                                # mythtv, power-options, romextract, uboot)
nix flake update                # bump inputs → updates flake.lock
nix flake lock                  # create/refresh lock without rebuilding
```

- `result` is gitignored — **never commit it**. Several directories also contain
  stray untracked build artifacts (`ctr/CTRPC.log`, `mpv/package-lock.json`,
  `mythtv/mythtv-35.0.tar.gz`, `uboot/u-boot-rk1.bin`) that are not gitignored;
  leave them alone unless you are regenerating them intentionally.
- flake.lock files **are** committed. When changing source URLs in flake.nix,
  run `nix flake update` (or `nix flake lock`) and commit both files.

## Workflow

- No lint, typecheck, or test suites exist; verification is a successful
  `nix build`. There are no `checks` or `apps` outputs to run (only
  `vacuumtube` defines `apps`).
- Commit messages are terse lowercase subjects (e.g. `update llama`, `wip turnstone`).
- Prefer one commit per flake when updating, matching existing history.

## Build helpers spotted

- Meson flakes set `mesonFlags` via `pkgs.lib.mesonEnable` / `mesonOption`
  (mpv, gamescope, libplacebo).
- CMake flakes use `pkgs.lib.strings.cmakeFeature` / `cmakeBool`
  (llama, dsda-doom).
- Some CMake flakes set the compiler via `CMAKE_HIP_COMPILER` and require env
  vars: `ROCM_PATH`, `HIP_DEVICE_LIB_PATH` (llama).
