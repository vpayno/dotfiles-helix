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

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      flake-utils,
      nixpkgs,
      treefmt-conf,
      rust-overlay,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pname = "dotfiles-helix";
        version = "20250415.0.0";
        name = "${pname}-${version}";

        overlays = [ (import rust-overlay) ];

        pkgs = import nixpkgs {
          inherit system overlays;
        };

      in
      {
        formatter = treefmt-conf.formatter.${system};

        devShells = {
          ci-test = pkgs.mkShell {
            buildInputs = with pkgs; [
              rust-bin.stable.latest.default # or .minimal
            ];
            shellHook = ''
              ${pkgs.lib.getExe pkgs.cowsay} "Welcome to .#ci-test devShell!"
              printf "\n"

              printf "rust version: "
              rustc --version
              printf "\n"
            '';
          };
        };
      }
    );
}
