{
  description = "bcm2835 library";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let system = flake-utils.lib.system;
    in flake-utils.lib.eachSystem [
      system.x86_64-linux
      system.aarch64-linux
      system.aarch64-darwin
      system.armv7l-linux
    ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        build-bcm2835 = (pkgs: pkgs.stdenv.mkDerivation {
            pname = "bcm2835";
            version = "1.75";
            src = pkgs.fetchurl {
              url = "http://www.airspayce.com/mikem/bcm2835/bcm2835-1.75.tar.gz";
              sha256 = "sha256-4+6P0Ka0depxyjYvwlh/oayf0D7THChWVIN3Mek0lv0=";
            };
            nativeBuildInputs = [ pkgs.binutils ];
        });
      in rec {
        packages = rec {
          bcm2835 = build-bcm2835 pkgs;
          bcm2835-cross-armv7l-linux =
            build-bcm2835 pkgs.pkgsCross.armv7l-hf-multiplatform;
          bcm2835-cross-aarch64-linux =
            build-bcm2835 pkgs.pkgsCross.aarch64-multiplatform;
          bcm2835-cross-aarch64-darwin =
            build-bcm2835 pkgs.pkgsCross.aarch64-darwin;
        };

        defaultPackage = packages.bcm2835;
      });
}
