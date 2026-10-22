{
  description = "Laporan Generator - development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        devShells.default = pkgs.mkShell {
          name = "laporan-generator";
          packages = [
            pkgs.pandoc
            pkgs.typst
            pkgs.python3
            pkgs.imagemagick_light
            pkgs.poppler-utils
            pkgs.unzip
            pkgs.gnumake
            pkgs.inotify-tools
          ];
        };
      });
}
