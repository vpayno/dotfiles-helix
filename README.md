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

```text
nix profile install nixpkgs#runme
```

## Reading

[Build from source](https://docs.helix-editor.com/install.html#build-from-source)

## Nix

Using Nix to run and install a pre-configured helix editor. Forgotten are the
days of having to install a program, then keeping it's configurations in sync,
making sure the running version and the configuration are compatible, et cetera.

### Running without installing

```bash { background=false category=info closeTerminalOnSuccess=true excludeFromRunAll=true interactive=true interpreter=bash name=run-helix promptEnv=true terminalRows=10 }
nix run github:vpayno/dotfiles-helix --
```

### Installing it

```bash { background=false category=info closeTerminalOnSuccess=true excludeFromRunAll=true interactive=true interpreter=bash name=install-helix promptEnv=true terminalRows=10 }
nix profile install github:vpayno/dotfiles-helix
```

Where is it installed?

```text
$ which hx
/home/vpayno/.nix-profile/bin/hx
```

Check the installed Helix version.

```bash { background=false category=info closeTerminalOnSuccess=true excludeFromRunAll=true interactive=true interpreter=bash name=verify-helix promptEnv=true terminalRows=10 }
hx --version
```

Example output:

```text
INFO: Using /nix/store/9cfxhfzsqwzfphacz5yn06rlng1qs96g-helix-config-dir as the config source.

INFO: Using /home/vpayno/.nix-profile/bin/hx as the wrapper script.

helix 25.01.1 (e7ac2fcd)
```

### Updating it

```bash { background=false category=info closeTerminalOnSuccess=true excludeFromRunAll=true interactive=true interpreter=bash name=update-helix promptEnv=true terminalRows=10 }
nix profile remove dotfiles-helix
```

### Uninstalling it

```bash { background=false category=info closeTerminalOnSuccess=true excludeFromRunAll=true interactive=true interpreter=bash name=uninstall-helix promptEnv=true terminalRows=10 }
nix profile remove dotfiles-helix
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
