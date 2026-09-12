# dotfiles

My dotfiles, managed with [chezmoi](https://www.chezmoi.io/).

The idea is simple: sit down at a fresh machine (Linux, macOS, or Windows) and get the same terminal experience everywhere.

## Features

- **WezTerm** with the Catppuccin Macchiato theme and a leader key workflow (tabs, splits, panes)
- **fish** with Catppuccin Macchiato colors, vi key bindings, and zoxide / atuin integration
- **Starship** single-line prompt with compact git info on the right (branch, stash, status counts, ahead/behind)
- **WSL2** via `/etc/wsl.conf` with the `metadata` mount for seamless Windows and WSL file permissions

## Install

```sh
chezmoi init --apply Viktor-V
```

## License

[MIT](LICENSE)
