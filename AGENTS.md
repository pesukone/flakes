# flakes

Collection of independent Nix flakes. Each top-level directory is a standalone flake with its own `flake.nix` and `flake.lock`. There is **no root flake.nix** — commands must be run inside a subdirectory.

## Structure

- 30 independent flakes, one per directory
- Each has its own inputs, lockfile, and build — they don't share state
- Common inputs: `nixpkgs` (unpinned to latest), `flake-utils`
- Sources are imported with `flake = false`

## Commands

All commands run from within a flake's directory (e.g., `cd rpcs3 && ...`):

```
nix build .#<pkg>      # Build a specific package, creates ./result symlink
nix build .#default    # Build the default package
nix build .            # Same as above
nix flake show .       # List all outputs (packages, devShells, etc.)
nix flake update       # Update all input pins in flake.lock
nix develop .          # Enter devShell (if defined)
```

## Output conventions

- Most flakes expose `packages.default` as the primary output
- Many also set `flakedPkgs = pkgs` (for overlay consumption)
- Some define `devShell` for development environments
- A few use `writeShellApplication` as `packages.default` to wrap launch scripts (`sm`, `gta`, `openmw`)

## Notable deviations from the common pattern

| Flake | Quirk |
|---|---|
| `ctr` | No `nixpkgs` input — relies entirely on upstream `ctr-sdk` flake for packages |
| `uboot` | No `flake-utils`; targets `aarch64-linux` and `armv7l-linux` explicitly |
| `install-iso` | Uses `nixosConfigurations` and `images` outputs, not `eachDefaultSystem` |
| `sm` | Bundles local `sm/sm.ini` into derivation via `${self}/sm.ini` |
| `nvim` | Builds mini.nvim plugins via `buildLuarocksPackage` + `buildNeovimPlugin` |
| `openmw` | Multi-stage: builds bullet3, mygui, collada-dom, osg as intermediates |
| `llama` | Complex ROCm/Vulkan/OpenVINO build; `postConfigure` fetches UI assets |
| `ace-step` | Python packages with `torchWithRocm`, `triton`, etc. |
| `gta` | Separate `-bin` and `-assets` packages, composed into `writeShellApplication` |

## Runtime data

Several game emulators expect ROMs/data at `~/roms/<game>/`. The `packages.default` for these flakes is a wrapper script that copies assets there at launch.

## Gotchas

- `.gitignore` only contains `result` — the symlink created by `nix build`
- No CI, tests, linting, or pre-commit hooks
- `nixpkgs` is unpinned (`github:nixos/nixpkgs` resolves to latest master)
- When adding packages, follow the existing pattern: `rec { packages.<name> = ...; packages.default = packages.<name>; }`
