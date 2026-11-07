# dotfiles

My dotfiles, managed with [chezmoi](https://www.chezmoi.io/).

The idea is simple: sit down at a fresh machine (Linux, macOS, or Windows) and get the same terminal experience everywhere.

## Features

- **WezTerm** with the Windows (Campbell) theme and a leader key workflow (tabs, splits, panes)
- **WezTerm startup** opens maximized on the Windows virtual desktop **«Консоль»**, switches to it, and launches **Herdr** (falls back to fish if unavailable)
- **fish** with Windows (Campbell) colors, vi key bindings, zoxide / atuin integration, and `~/.local/bin` + `~/.opencode/bin` in `PATH`
- **SSH sessions** (for example from a phone) hide `/mnt/*` Windows paths so terminal clients treat WSL as a Unix host
- **Starship** single-line prompt with compact git info on the right (branch, stash, status counts, ahead/behind)
- **Flow Launcher** configured with the Windows theme
- **Windows shell** with hidden desktop icons
- **WSL2** via `/etc/wsl.conf` with the `metadata` mount for seamless Windows and WSL file permissions

## Install

```sh
chezmoi init --apply Viktor-V
```

## License

[MIT](LICENSE)
