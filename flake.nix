{
  description = "zig";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    zig-overlay.url = "github:mitchellh/zig-overlay";
  };

  outputs = { nixpkgs, zig-overlay, ... }:
  let
    forEachAllSystems = f: nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed
      (system: f { pkgs = import nixpkgs { inherit system; }; inherit zig-overlay; } );
  in {
    devShells = forEachAllSystems({pkgs, zig-overlay}: {
      default = let
        system = pkgs.stdenv.system;
      in pkgs.mkShell {
        packages = with pkgs; [
          zig-overlay.packages.${system}.default
          typos
          zls
        ];
      };
    });
  };
}
