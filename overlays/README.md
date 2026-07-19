# Overlays

Overlay auto-discovery is currently disabled (see `modules/shared/default.nix`); files here must be wired in manually via the `nixpkgs.overlays` list in `flake.nix`. Some common ways I've used overlays in the past:
* Applying patches
* Downloading different versions of files (locking to a version or trying a fork)
* Workarounds and stuff I need to run temporarily
