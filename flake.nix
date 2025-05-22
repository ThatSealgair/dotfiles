{
  description = "Home Manager configuration with Ghostty and nixGL";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl.url = "github:nix-community/nixGL";
  };

  outputs = { self, nixpkgs, home-manager, nixgl, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      nixGLPkgs = import nixgl { inherit pkgs system; };
    in {
      homeConfigurations = {
        sealgair = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home.nix
            ({ pkgs, ... }: {
              # Make nixGL available as an argument in home.nix
              _module.args.nixGL = nixGLPkgs;
            })
          ];
        };
      };
    };
}

