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

Using [this](https://github.com/LGUG2Z/helix-vim) config to make helix more vim-like.
