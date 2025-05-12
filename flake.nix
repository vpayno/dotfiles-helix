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

        metadata = {
          homepage = "https://github.com/vpayno/dotfiles-helix";
          description = "Personal pre-configured helix editor";
          license = with pkgs.lib.licenses; [ mit ];
          # maintainers = with pkgs.lib.maintainers; [vpayno];
          maintainers = [
            {
              email = "vpayno@users.noreply.github.com";
              github = "vpayno";
              githubId = 3181575;
              name = "Victor Payno";
            }
          ];
          mainProgram = "hx";
        };

        usageMessage = ''
          Available ${name} flake commands:

            nix run .#usage

            nix run . -- "message"
              nix run .#default -- helix args
              nix run .#hx      -- helix args

            nix profile install github:vpayno/dotfiles-helix
        '';

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

        helixConfigDir = pkgs.stdenv.mkDerivation {
          name = "helix-config-dir";
          src = ./.;
          buildInputs = with pkgs; [
            coreutils
            tree
          ];
          installPhase = ''
            ls $src

            mkdir -pv $out

            cp -v "$src"/config.toml "$out"/
            cp -v "$src"/languages.toml "$out"/
            cp -vr "$src"/themes "$out"/

            ln -sv "${pkgs.helix}/lib/runtime" "$out"/runtime

            tree "$out"/
          '';
        };

        toolPkgs = with pkgs; [
          jq
          taplo-cli # get, fmt, lint, lsp
          xmlstarlet
          yq-go
        ];

        lintPkgs = with pkgs; [
          shellcheck
          yamllint
        ];

        fmtPkgs = with pkgs; [
          jsonfmt
          shfmt
          xmlformat
          yamlfix
        ];

        lspPkgs = with pkgs; [
          bash-language-server
          lemminx
          spectral-language-server
          yaml-language-server
        ];

        /*
          Notes:
          - hx doesn't support custom configuration directories so the wrapper script
            has to insert it's configuration directory in the default location.
          - the wrapper script places the host's PATH at the end of it's PATH so you
            can provide per-project versions using `nix develop` and `devbox shell`.
        */
        helixWrapper = pkgs.writeShellApplication {
          name = "hx";
          runtimeInputs =
            with pkgs;
            [
              bashInteractive
              coreutils
              helix
              moreutils
            ]
            ++ toolPkgs
            ++ lintPkgs
            ++ fmtPkgs
            ++ lspPkgs;
          text = ''
            if [[ -d ~/.config/helix ]] && [[ ! -L ~/.config/helix ]]; then
              printf "INFO: renaming found config directory\n"
              mv -v ~/.config/helix{,-"''$(date +%Y%m%d-%H%M%S)"}
              printf "\n"
            fi

            if [[ ! -e ~/.config/helix ]] || [[ $(realpath ~/.config/helix) != ${helixConfigDir} ]]; then
              printf "INFO: Creating config symlink to /nix/store...\n"
              ln -nsfv ${helixConfigDir} ~/.config/helix
              printf "\n"
            fi

            printf "INFO: Using %s as the config source.\n" "${helixConfigDir}"
            printf "\n"

            printf "INFO: Using %s as the wrapper script.\n" "$0"
            printf "\n"

            exec hx --config ${helixConfigDir}/config.toml "$@"
          '';
        };
      in
      {
        formatter = treefmt-conf.formatter.${system};

        packages = rec {
          default = hx;

          hx = {
            pname = "nix-helix-conf";
            inherit version;
            name = "${pname}-${version}";
          } // helixWrapper;

          # very odd, this doesn't work with pkgs.writeShellApplication
          # odd quoting error when the string usagemessage as new lines
          showUsage = pkgs.writeShellScriptBin "showUsage" ''
            printf "%s" "${usageMessage}"
          '';
        };

        apps = rec {
          default = hx;

          hx = {
            type = "app";
            program = "${pkgs.lib.getExe helixWrapper}";
            meta = metadata;
          };

          usage = {
            type = "app";
            pname = "usage";
            inherit version;
            name = "${pname}-${version}";
            program = "${pkgs.lib.getExe self.packages.${system}.showUsage}";
            meta = metadata;
          };
        };

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
