{
  description = "Pixum Fotowelt (CEWE-based photo book software) packaged for Nix";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfreePredicate = pkg: nixpkgs.lib.getName pkg == "pixum-fotowelt";
      };
    in
    {
      packages.${system} = {
        pixum-fotowelt = pkgs.callPackage ./package.nix { };
        default = self.packages.${system}.pixum-fotowelt;
      };

      apps.${system}.default = {
        type = "app";
        program = nixpkgs.lib.getExe self.packages.${system}.pixum-fotowelt;
        meta.description = "Run Pixum Fotowelt";
      };

      # For NixOS/home-manager configs. The consumer must allow the unfree license.
      overlays.default = final: prev: {
        pixum-fotowelt = final.callPackage ./package.nix { };
      };
    };
}
