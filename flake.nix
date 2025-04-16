{
  inputs = {
    nixpkgs.url = "github:nixOS/nixpkgs/nixos-unstable";

    systems.url = "github:vpayno/nix-systems-default";

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    treefmt-conf = {
      url = "github:vpayno/nix-treefmt-conf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      flake-utils,
      nixpkgs,
      treefmt-conf,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pname = "dotfiles-helix";
        version = "20250415.0.0";
        name = "${pname}-${version}";
      in
      {
        formatter = treefmt-conf.formatter.${system};
      }
    );
}
