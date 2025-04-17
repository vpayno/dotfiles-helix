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

        ci-run-markdownlint-cli = pkgs.writeScriptBin "ci-run-markdownlint-cli" ''
          # CHANGELOG.md:5:1 MD033/no-inline-html Inline HTML [Element: h2]
          # CHANGELOG.md:9 MD001/heading-increment/header-increment Heading levels should only increment by one level at a time [Expected: h2; Actual: h3]

          ${pkgs.lib.getExe pkgs.markdownlint-cli} $INPUT_MARKDOWNCLI_IGNORE $INPUT_MARKDOWNCLI_FLAGS "$@"
        '';

        markdownlint-cli-with-reviewdog = pkgs.writeScriptBin "markdownlint-cli-with-reviewdog" ''
          printf "Running %s ci linter...\n" "markdownlint-cli"
          printf "\n"

          ${pkgs.lib.getExe ci-run-markdownlint-cli} |
            ${pkgs.lib.getExe pkgs.gnused} -r -e 's/^(.*[.]md:[0-9]+) (.*)$/\1:1 \2/g' |
              ${pkgs.lib.getExe pkgs.reviewdog} -tee -efm="%f:%l:%c: %m" -name="markdownlint" \
              -reporter="$INPUT_REPORTER" \
              -fail-level="$INPUT_FAIL_LEVEL"

          printf "Done\n"
        '';

        ci-run-yamllint = pkgs.writeScriptBin "ci-run-yamllint" ''
          ${pkgs.lib.getExe pkgs.yamllint} ''${INPUT_YAMLLINT_FLAGS:-'.'} "$@"
        '';

        yamllint-with-reviewdog = pkgs.writeScriptBin "yamllint-with-reviewdog" ''
          printf "Running %s ci linter...\n" "yamllint"
          printf "\n"

          ${pkgs.lib.getExe ci-run-yamllint} |
            ${pkgs.lib.getExe pkgs.reviewdog} \
              -efm="%f:%l:%c: %m" \
              -name "yamllint" \
              -reporter="''${INPUT_REPORTER:-github-pr-check}" \
              -level="''${INPUT_LEVEL}" \
              -filter-mode="''${INPUT_FILTER_MODE}" \
              -fail-level="''${INPUT_FAIL_LEVEL}" \
              ''${INPUT_REVIEWDOG_FLAGS}

          printf "Done\n"
        '';

        ci-run-actionlint = pkgs.writeScriptBin "ci-run-actionlint" ''
          #  echo "::add-matcher::.github/actionlint-matcher.json"
          for f in ./.github/workflows/*yml; do
            ${pkgs.lib.getExe pkgs.actionlint} ''${INPUT_ACTIONLINT_FLAGS:-'-oneline'} "$f" "$@"
          done
        '';

        actionlint-with-reviewdog = pkgs.writeScriptBin "actionlint-with-reviewdog" ''
          printf "Running %s ci linter...\n" "actionlint"
          printf "\n"

          ${pkgs.lib.getExe ci-run-actionlint} |
            ${pkgs.lib.getExe pkgs.reviewdog} \
              -efm="%f:%l:%c: %m" \
              -name "actionlint" \
              -reporter="''${INPUT_REPORTER:-github-pr-check}" \
              -level="''${INPUT_LEVEL}" \
              -filter-mode="''${INPUT_FILTER_MODE}" \
              -fail-level="''${INPUT_FAIL_LEVEL}" \
              ''${INPUT_REVIEWDOG_FLAGS}

          printf "Done\n"
        '';
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
          ci-markdown = pkgs.mkShell {
            buildInputs =
              with pkgs;
              [
                markdownlint-cli
                reviewdog
              ]
              ++ [
                ci-run-markdownlint-cli
                markdownlint-cli-with-reviewdog
              ];
            shellHook = ''
              ${pkgs.lib.getExe pkgs.cowsay} "Welcome to .#ci-markdown devShell!"
              printf "\n"

              printf "reviewdog version: "
              reviewdog --version
              printf "markdownlint-cli version: "
              markdownlint --version
              printf "\n"

              export INPUT_MARKDOWNCLI_IGNORE="--ignore ./pages-gh"
              export INPUT_MARKDOWNCLI_FLAGS="."

              export INPUT_LEVEL="error"
              export INPUT_REPORTER="github-check" # github-check github-pr-check github-pr-review github-pr-annotations
              export INPUT_FAIL_LEVEL="any" # any error
            '';
          };
          ci-yaml = pkgs.mkShell {
            buildInputs =
              with pkgs;
              [
                reviewdog
                yamllint
              ]
              ++ [
                ci-run-yamllint
                yamllint-with-reviewdog
              ];
            shellHook = ''
              ${pkgs.lib.getExe pkgs.cowsay} "Welcome to .#ci-yaml devShell!"
              printf "\n"

              printf "reviewdog version: "
              reviewdog --version
              printf "yamllint version: "
              yamllint --version
              printf "\n"

              export INPUT_YAMLLINT_FLAGS="."

              export INPUT_LEVEL="error"
              export INPUT_REPORTER="github-check" # github-check github-pr-check github-pr-review github-pr-annotations
              export INPUT_FAIL_LEVEL="any" # any error
            '';
          };
          ci-actionlint = pkgs.mkShell {
            buildInputs =
              with pkgs;
              [
                actionlint
                reviewdog
                shellcheck
              ]
              ++ [
                ci-run-actionlint
                actionlint-with-reviewdog
              ];
            shellHook = ''
              ${pkgs.lib.getExe pkgs.cowsay} "Welcome to .#ci-actionlint devShell!"
              printf "\n"

              printf "reviewdog version: "
              reviewdog --version
              printf "actionlint version: "
              actionlint --version
              printf "shellcheck version: "
              shellcheck --version
              printf "\n"

              export INPUT_ACTIONLINT_FLAGS="-oneline"

              export INPUT_LEVEL="error"
              export INPUT_REPORTER="github-check" # github-check github-pr-check github-pr-review github-pr-annotations
              export INPUT_FAIL_LEVEL="any" # any error
            '';
          };
        };
      }
    );
}
