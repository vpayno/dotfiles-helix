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

        ci-run-markdownlint-cli = pkgs.writeShellApplication {
          name = "ci-run-markdownlint-cli";
          text = ''
            # CHANGELOG.md:5:1 MD033/no-inline-html Inline HTML [Element: h2]
            # CHANGELOG.md:9 MD001/heading-increment/header-increment Heading levels should only increment by one level at a time [Expected: h2; Actual: h3]

            if [[ -z ''${INPUT_MARKDOWNCLI_IGNORE:-} ]]; then
              export INPUT_MARKDOWNCLI_IGNORE=("--ignore" "./pages-gh")
            fi
            if [[ -z ''${INPUT_MARKDOWNCLI_FLAGS:-} ]]; then
              export INPUT_MARKDOWNCLI_FLAGS=(".")
            fi

            ${pkgs.lib.getExe pkgs.markdownlint-cli} "''${INPUT_MARKDOWNCLI_IGNORE[@]:-}" "''${INPUT_MARKDOWNCLI_FLAGS[@]}" "''${@}"
          '';
        };

        markdownlint-cli-with-reviewdog = pkgs.writeShellApplication {
          name = "markdownlint-cli-with-reviewdog";
          text = ''
            printf "Running %s ci linter...\n" "markdownlint-cli"
            printf "\n"

            ${pkgs.lib.getExe ci-run-markdownlint-cli} |
              ${pkgs.lib.getExe pkgs.gnused} -r -e 's/^(.*[.]md:[0-9]+) (.*)$/\1:1 \2/g' |
                ${pkgs.lib.getExe pkgs.reviewdog} -tee -efm="%f:%l:%c: %m" -name="markdownlint" \
                -reporter="''${INPUT_REPORTER:-github-pr-check}" \
                -fail-level="''${INPUT_FAIL_LEVEL:-any}"

            printf "Done\n"
          '';
        };

        ci-run-yamllint = pkgs.writeShellApplication {
          name = "ci-run-yamllint";
          text = ''
            ${pkgs.lib.getExe pkgs.yamllint} "''${INPUT_YAMLLINT_FLAGS[@]:-'.'}" "$@"
          '';
        };

        yamllint-with-reviewdog = pkgs.writeShellApplication {
          name = "yamllint-with-reviewdog";
          text = ''
            printf "Running %s ci linter...\n" "yamllint"
            printf "\n"

            ${pkgs.lib.getExe ci-run-yamllint} |
              ${pkgs.lib.getExe pkgs.reviewdog} \
                -efm="%f:%l:%c: %m" \
                -name "yamllint" \
                -reporter="''${INPUT_REPORTER:-github-pr-check}" \
                -level="''${INPUT_LEVEL:-error}" \
                -filter-mode="''${INPUT_FILTER_MODE:-added}" \
                -fail-level="''${INPUT_FAIL_LEVEL:-any}" \
                "''${INPUT_REVIEWDOG_FLAGS[@]:-}"

            printf "Done\n"
          '';
        };

        ci-run-actionlint = pkgs.writeShellApplication {
          name = "ci-run-actionlint";
          text = ''
            #  echo "::add-matcher::.github/actionlint-matcher.json"
            for f in ./.github/workflows/*yml; do
              ${pkgs.lib.getExe pkgs.actionlint} "''${INPUT_ACTIONLINT_FLAGS[@]:--oneline}" "$f" "$@"
            done
          '';
        };

        actionlint-with-reviewdog = pkgs.writeShellApplication {
          name = "actionlint-with-reviewdog";
          text = ''

            printf "Running %s ci linter...\n" "actionlint"
            printf "\n"

            ${pkgs.lib.getExe ci-run-actionlint} |
              ${pkgs.lib.getExe pkgs.reviewdog} \
                -efm="%f:%l:%c: %m" \
                -name "actionlint" \
                -reporter="''${INPUT_REPORTER:-github-pr-check}" \
                -level="''${INPUT_LEVEL:-error}" \
                -filter-mode="''${INPUT_FILTER_MODE:-added}" \
                -fail-level="''${INPUT_FAIL_LEVEL:-any}" \
                "''${INPUT_REVIEWDOG_FLAGS[@]:-}"

            printf "Done\n"
          '';
        };

        # first line needs to be a number
        cargoSpellcheckDictionary = pkgs.writeText ".config/mywords.dic" ''
          100
          Changelog
          Nix
          NixOS
          README
          TODO
          UTF-8
          cli
          macOS
          nix
          nixos
        '';

        # generate: cargo-spellcheck config
        # fix: the ''' quotes need to be '''' for Nix
        cargoSpellcheckConfig = pkgs.writeText ".config/spellcheck.toml" ''
          dev_comments = false
          skip_readme = false

          [hunspell]
          lang = "en_US"
          search_dirs = []
          skip_os_lookups = false
          use_builtin = true
          tokenization_splitchars = ''''",;:.!?#(){}[]|/_-‒'`&@§¶…''''
          extra_dictionaries = [ "${cargoSpellcheckDictionary}" ]

          [hunspell.quirks]
          transform_regex = []
          allow_concatenation = false
          allow_dashes = false
          allow_emojis = true
          check_footnote_references = true

          [zet]
          lang = "en_US"
          search_dirs = []
          skip_os_lookups = false
          use_builtin = true
          tokenization_splitchars = ''''",;:.!?#(){}[]|/_-‒'`&@§¶…''''
          extra_dictionaries = [ "${cargoSpellcheckDictionary}" ]

          [zet.quirks]
          transform_regex = []
          allow_concatenation = false
          allow_dashes = false
          allow_emojis = true
          check_footnote_references = true

          [spellbook]
          lang = "en_US"
          search_dirs = []
          skip_os_lookups = false
          use_builtin = true
          tokenization_splitchars = ''''",;:.!?#(){}[]|/_-‒'`&@§¶…''''
          extra_dictionaries = [ "${cargoSpellcheckDictionary}" ]

          [spellbook.quirks]
          transform_regex = []
          allow_concatenation = false
          allow_dashes = false
          allow_emojis = true
          check_footnote_references = true

          [nlprules]

          [reflow]
          max_line_length = 120
        '';

        ci-run-spellcheck = pkgs.writeShellApplication {
          name = "ci-run-spellcheck";
          text = ''
            ${pkgs.lib.getExe pkgs.cargo-spellcheck} --cfg "${cargoSpellcheckConfig}" "''${INPUT_SPELLCHECK_FLAGS[@]:-check}" "$@"
          '';
        };

        spellcheck-with-reviewdog = pkgs.writeShellApplication {
          name = "spellcheck-with-reviewdog";
          text = ''
            printf "Running %s ci linter...\n" "spellcheck"
            printf "\n"

            ${pkgs.lib.getExe ci-run-spellcheck} |
              ${pkgs.lib.getExe pkgs.reviewdog} \
                -efm="%f:%l:%c: %m" \
                -name "spellcheck" \
                -reporter="''${INPUT_REPORTER:-github-pr-check}" \
                -level="''${INPUT_LEVEL:-error}" \
                -filter-mode="''${INPUT_FILTER_MODE:-added}" \
                -fail-level="''${INPUT_FAIL_LEVEL:-any}" \
                "''${INPUT_REVIEWDOG_FLAGS[@]:-}"

            printf "Done\n"
          '';
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

              export INPUT_MARKDOWNCLI_IGNORE=("--ignore" "./pages-gh")
              export INPUT_MARKDOWNCLI_FLAGS=(".")

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

              export INPUT_ACTIONLINT_FLAGS=("-oneline")

              export INPUT_LEVEL="error"
              export INPUT_REPORTER="github-check" # github-check github-pr-check github-pr-review github-pr-annotations
              export INPUT_FAIL_LEVEL="any" # any error
            '';
          };
          ci-spellcheck = pkgs.mkShell {
            buildInputs =
              with pkgs;
              [
                cargo-spellcheck
                reviewdog
              ]
              ++ [
                ci-run-spellcheck
                actionlint-with-reviewdog
              ];
            shellHook = ''
              ${pkgs.lib.getExe pkgs.cowsay} "Welcome to .#ci-spellcheck devShell!"
              printf "\n"

              printf "reviewdog version: "
              reviewdog --version
              printf "cargo-spellcheck version: "
              cargo-spellcheck --version
              printf "\n"

              export INPUT_SPELLCHECK_FLAGS=("check")

              export INPUT_LEVEL="error"
              export INPUT_REPORTER="github-check" # github-check github-pr-check github-pr-review github-pr-annotations
              export INPUT_FAIL_LEVEL="any" # any error
            '';
          };
        };
      }
    );
}
