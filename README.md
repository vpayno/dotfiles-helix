# dotfiles-helix

[![GitHub Action Workflow](https://github.com/vpayno/dotfiles-helix/actions/workflows/gh-actions.yml/badge.svg?branch=main)](https://github.com/vpayno/dotfiles-helix/actions/workflows/gh-actions.yml)
[![Markdown Checks](https://github.com/vpayno/dotfiles-helix/actions/workflows/markdown.yml/badge.svg?branch=main)](https://github.com/vpayno/dotfiles-helix/actions/workflows/markdown.yml)
[![Shellcheck Workflow](https://github.com/vpayno/dotfiles-helix/actions/workflows/shellcheck.yml/badge.svg?branch=main)](https://github.com/vpayno/dotfiles-helix/actions/workflows/shellcheck.yml)
[![Spelling Workflow](https://github.com/vpayno/dotfiles-helix/actions/workflows/misspell.yml/badge.svg?branch=main)](https://github.com/vpayno/dotfiles-helix/actions/workflows/misspell.yml)
[![Tests Workflow](https://github.com/vpayno/dotfiles-helix/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/vpayno/dotfiles-helix/actions/workflows/tests.yml)
[![Yaml Workflow](https://github.com/vpayno/dotfiles-helix/actions/workflows/yaml.yml/badge.svg?branch=main)](https://github.com/vpayno/dotfiles-helix/actions/workflows/yaml.yml)

My configuration repo for the Helix editor.

## RunMe Playbook

This and other readme files in this repo are RunMe Plabooks.

Use this playbook step/task to update the [RunMe](https://runme.dev) cli.

If you don't have runme installed, you'll need to copy/paste the command. :)

```bash { background=false category=runme closeTerminalOnSuccess=true excludeFromRunAll=true interactive=true interpreter=bash name=setup-install-runme promptEnv=true terminalRows=10 }
go install github.com/stateful/runme/v3@v3
```

## Reading

[Build from source](https://docs.helix-editor.com/install.html#build-from-source)

## Installation

- Installing directly from GitHub:

```bash { background=false category=install closeTerminalOnSuccess=true excludeFromRunAll=true interactive=true interpreter=bash name=install-from-github promptEnv=true terminalRows=10 }
cargo install --git https://github.com/helix-editor/helix.git --tag "$(git ls-remote --tags https://github.com/helix-editor/helix.git | sed -r -e 's:.*/::g' | grep -E '^[0-9]+[.][0-9]+([.][0-9]+)?$' | sort -rV | head -n 1)" helix-term
```

- Clone the dotfiles repo:

```bash { background=false category=dotfiles closeTerminalOnSuccess=true excludeFromRunAll=true interactive=true interpreter=bash name=install-dotfiles promptEnv=true terminalRows=10 }
git clone --recursive -j 8 https://github.com/vpayno/dotfiles-helix ~/.config/helix
```

- Checkout the latest tag, build and install Helix.

```bash { background=false category=install closeTerminalOnSuccess=true excludeFromRunAll=true interactive=true interpreter=bash name=install-from-dotfiles promptEnv=true terminalRows=10 }
cd ~/.config/helix/helix.git

git switch --detach "$(git tag | grep -E '^[2-9][0-9][.][0-9]+([.][0-9]+)?$' | tail -n 1)"

cargo install --path helix-term
```

- Check the installed Helix version.

```bash { background=false category=info closeTerminalOnSuccess=true excludeFromRunAll=true interactive=true interpreter=bash name=verify-version promptEnv=true terminalRows=10 }
hx --version
# helix 24.3 (2cadec0b)
```

## Themes

[Theme Documentation](https://github.com/helix-editor/helix/wiki/Themes)

## Book/Documentation

[Helix Online Book](https://docs.helix-editor.com/title-page.html)

## Configuration

Using [this](https://github.com/LGUG2Z/helix-vim) config to make helix more
vim-like.

## CI

### Nix Develop

Using `nix develop .#ci-label` to setup environment variables inside of CI jobs
to manage configurations and packages.

To install `nix`, use these GitHub actions:

```yaml
- name: Install Nix
  uses: DeterminateSystems/nix-installer-action@main
- name: Check Nixpkgs inputs
  uses: DeterminateSystems/flake-checker-action@main
  with:
    fail-mode: true
```

To run a CI job run it via `nix develop`:

```yaml
- name: markdownlint with reviewdog
  id: run-markdownlint
  run: nix develop .#ci-markdown --command markdownlint-cli-with-reviewdog
```

The CI code is now in `flake.nix`.

```text
$ nix flake show
git+file:///home/vpayno/git_vpayno/dotfiles-helix
├───devShells
│   └───x86_64-linux
│       ├───ci-actionlint: development environment 'nix-shell'
│       ├───ci-markdown: development environment 'nix-shell'
│       ├───ci-spellcheck: development environment 'nix-shell'
│       ├───ci-test: development environment 'nix-shell'
│       └───ci-yaml: development environment 'nix-shell'
└───formatter
    ├───aarch64-darwin omitted (use '--all-systems' to show)
    ├───aarch64-linux omitted (use '--all-systems' to show)
    ├───riscv64-linux omitted (use '--all-systems' to show)
    ├───x86_64-darwin omitted (use '--all-systems' to show)
    └───x86_64-linux: package 'treefmt'
```

Starting a development shell is easy:

```text
$ nix develop .#ci-markdown
 ____________________________________
< Welcome to .#ci-markdown devShell! >
 ------------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||

reviewdog version: 0.20.3
markdownlint-cli version: 0.44.0

$ which reviewdog markdownlint
/nix/store/qisrmw6ddhm4myqz8w12v6lvy6532qsa-reviewdog-0.20.3/bin/reviewdog
/nix/store/f4ya4xc7mpy1kndx69vzmpsr4z4wjjfp-markdownlint-cli-0.44.0/bin/markdownlint

$ exit
```

For example, to simplify calling `reviewdog` and `markdownlint` programs, the
flake includes wrapper shell scripts:

```text
$ which ci-run-markdownlint-cli markdownlint-cli-with-reviewdog
/nix/store/fqfgyf4nk2h5yca2qzh6p4bl50nn1dny-ci-run-markdownlint-cli/bin/ci-run-markdownlint-cli
/nix/store/1ac4crcy5gck4ryspp90sq0wfr22ibm1-markdownlint-cli-with-reviewdog/bin/markdownlint-cli-with-reviewdog
```
