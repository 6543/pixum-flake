# pixum-flake

Nix flake for **Pixum Fotowelt**, the desktop software for designing and ordering photo books, calendars and other photo products from [Pixum](https://www.pixum.de/).

Pixum Fotowelt is a branded build of the CEWE photo software. Pixum ships a Linux version, but only as a Perl installer that downloads everything into your home directory. This flake packages the same files as a normal Nix package instead.

> [!NOTE]
> This is an unofficial community package. It is not affiliated with or supported by Pixum or CEWE.
> The software itself is proprietary and covered by its own EULA (`EULA.txt` in the vendor download).

## What you get

- `pixum-fotowelt` command
- Desktop entry and icons
- File type for saved projects (`.mcf` / `.mcfx`)

Current version: **8.1.3** (German Pixum edition, `de_DE`).

## Requirements

- `x86_64-linux` (the vendor only builds for 64-bit x86)
- Working OpenGL drivers, on NixOS `hardware.graphics.enable = true;` (on by default with most desktop setups)
- Allowing the unfree license for this package (see below)
- About 750 MB download, 1.4 GB in the Nix store

## Usage

### Try it

```sh
nix run github:6543/pixum-flake
```

The flake allows the unfree license for this one package, so no extra setting is needed for `nix run`, `nix build` or `nix profile add`.

### Install into your profile

```sh
nix profile add github:6543/pixum-flake
```

### NixOS configuration

Add the flake as an input and use its overlay:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    pixum-flake = {
      url = "github:6543/pixum-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, pixum-flake, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ pkgs, lib, ... }: {
          nixpkgs.overlays = [ pixum-flake.overlays.default ];
          nixpkgs.config.allowUnfreePredicate = pkg: lib.getName pkg == "pixum-fotowelt";
          environment.systemPackages = [ pkgs.pixum-fotowelt ];
        })
      ];
    };
  };
}
```

The overlay builds the package with your own nixpkgs, so you have to allow the unfree license yourself. You can also skip the overlay and use `pixum-flake.packages.x86_64-linux.default` directly.

## How it works

The vendor installer reads an index file from Pixum's download server and fetches a set of 7z archives. `package.nix` pins the archives the installer would pick for 64-bit Linux and does the same steps the installer does:

1. Unpack all archives into `$out/opt/pixum-fotowelt`.
2. Create the `libfoo.so` / `libfoo.so.N` symlinks for the bundled libraries.
3. Patch the binaries with `autoPatchelfHook` so they find system libraries on NixOS.
4. Add a wrapper, desktop entry, icons and MIME type.

The app bundles its own Qt 6 and QtWebEngine.

User data ends up in `~/.mcf`, `~/.config/CeWe Color` and `~/.cache/Pixum Fotowelt`, the same places as with the vendor installer.

## Differences from the vendor installer

- **No built-in updater.** It would try to write into the read-only Nix store. Updates come from bumping this flake.
- **No Pixum Fotoschau menu entry.** The binary is included in `opt/pixum-fotowelt`, but only the main app gets a desktop entry.
- **No install statistics.** The vendor installer reports download and install events to Pixum's server. Nix only downloads the archives.
- **No `/bin/pidof` needed.** The app runs the hardcoded `/bin/pidof` at startup and hangs on the splash screen without it, which is the case on NixOS. The package rewrites that path in `libCWCore` to a `pidof` from procps shipped next to the app.
- **Always runs on X11.** On native Wayland with a GPU the embedded web view (start page, shop) stays blank. The wrapper sets `QT_QPA_PLATFORM=xcb`, so Wayland sessions need XWayland.

## Updating to a new Pixum version

1. Find the current version in the vendor installer:

   ```sh
   curl -sL https://dls.photoprintit.com/download/Data/1291-de_DE/hps/setup_Pixum_Fotowelt.tgz | tar -xzO install.pl | grep -F 'my $HPS_VER'
   ```

2. Fetch the index for that version (replace `X.Y.Z`):

   ```sh
   curl -s https://dls.photoprintit.com/download/Data/1291-de_DE/hps/38-index-X.Y.Z.txt
   ```

3. Take every line ending in `;a` (all platforms) or `;l64` (64-bit Linux). The first field is the path below `https://dls.photoprintit.com/`.

4. Get the hash for each archive:

   ```sh
   nix store prefetch-file https://dls.photoprintit.com/<path>
   ```

5. Update `version` and the `archives` list in `package.nix`, then build and run:

   ```sh
   nix build .# && ./result/bin/pixum-fotowelt
   ```

## Status

Tested with version 8.1.3 on `nixos-26.05`:

- Builds, and all library dependencies resolve.
- The app starts, shows the start screen and loads the online start page.

Not tested yet:

- Designing and ordering a full photo book
- Hardware-accelerated GPUs (tested with Mesa software rendering)

Reports and fixes are welcome.

## Other Pixum and CEWE editions

Other shops use the same software with a different key account and locale, for example CEWE Fotowelt or dm-Fotowelt. Adapting `keyAccount`, the locale in the URLs and the archive list in `package.nix` should work for them too, but only the German Pixum edition has been tested.
