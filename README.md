# dotfiles-helix

My configuration repo for the Helix editor.

## Badges

[![GitHub Action Workflow](https://github.com/vpayno/dotfiles-helix/actions/workflows/gh-actions.yml/badge.svg?branch=main)](https://github.com/vpayno/dotfiles-helix/actions/workflows/gh-actions.yml)
[![Markdown Checks](https://github.com/vpayno/dotfiles-helix/actions/workflows/markdown.yml/badge.svg?branch=main)](https://github.com/vpayno/dotfiles-helix/actions/workflows/markdown.yml)
[![Spelling Workflow](https://github.com/vpayno/dotfiles-helix/actions/workflows/misspell.yml/badge.svg?branch=main)](https://github.com/vpayno/dotfiles-helix/actions/workflows/misspell.yml)
[![Yaml Workflow](https://github.com/vpayno/dotfiles-helix/actions/workflows/yaml.yml/badge.svg?branch=main)](https://github.com/vpayno/dotfiles-helix/actions/workflows/yaml.yml)

## Reading

[Build from source](https://docs.helix-editor.com/install.html#build-from-source)

## Installation

- Clone the dotfiles repo:

```bash
git clone --recursive -j 8 https://github.com:vpayno/dotfiles-helix ~/.config/helix
```

- Checkout the latest tag, build and install Helix.

```bash
cd ~/.config/helix/helix.git

git switch --detach "$(git tag | grep -E '^[2-9][0-9][.][0-9]+([.][0-9]+)?$' | tail -n 1)"

cargo install --path helix-term
```

- Check the installed Helix version.

```bash
$ hx --version
helix 22.12 (96ff64a8)
```

## Themes

[Theme Documentation](https://github.com/helix-editor/helix/wiki/Themes)

## Book/Documentation

[Helix Online Book](https://docs.helix-editor.com/title-page.html)
