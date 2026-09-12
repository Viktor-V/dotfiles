# dotfiles

My dotfiles, managed with [chezmoi](https://www.chezmoi.io/).

The idea is simple: sit down at a fresh machine (Linux, macOS, or Windows) and get the same terminal experience everywhere.

## Features

- **WezTerm** with the Catppuccin Macchiato theme and a leader key workflow (tabs, splits, panes)
- **WSL2** via `/etc/wsl.conf` with the `metadata` mount for seamless Windows and WSL file permissions

## Install

```sh
chezmoi init --apply Viktor-V
```

## License

[MIT](LICENSE)
