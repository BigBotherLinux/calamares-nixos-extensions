{
  description = "NixOS configuration";  
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
  };  
  outputs = { nixpkgs, ... }: 
  {
    nixosConfigurations = {
      nixtst = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ({ config, pkgs, ... }:
            ./configuration.nix
          )
        ];
      };
    };
  };
}