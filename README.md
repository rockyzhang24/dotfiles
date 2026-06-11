# .dotfiles

My development environment for `macOS` and `Linux`.

Built around a highly customized Neovim setup, terminal-first workflows, and a carefully crafted macOS environment.

## Highlights:

- **Neovim**: A highly customized setup focused on stability, simplicity, and full control. Most functionality is implemented from scratch rather than delegated to plugins
- **FZF**: A heavily customized terminal workflow built around fzf for fast navigation, searching, and command execution
- **Terminal**: Kitty / Ghostty, Tmux, and Zsh (Zimfw + Starship) form the foundation of a productive terminal environment
- **File Management**: A carefully crafted lf setup for efficient keyboard-driven file navigation and manipulation
- **macOS Workflow**: Karabiner-Element, SketchyBar, and Yabai provide a fully keyboard-driven desktop experience

📖 **Neovim Documentation**

For a detailed walkthrough of my Neovim configuration and custom modules: [Nvim README](./.config/nvim/README.md)

![demo](https://github.com/user-attachments/assets/de888ec1-a391-48f2-b951-0a7dfabdbb90)

# Configurations

### Neovim

* [Neovim](https://neovim.io) ([config](./.config/nvim/) and [README](./.config/nvim/README.md))

### Terminal

* [Ghostty](https://ghostty.org/) ([config](./.config/ghostty/))
* [Kitty](https://sw.kovidgoyal.net/kitty/) ([config](./.config/kitty/))
* [Wezterm](https://wezfurlong.org/wezterm/) ([config](./.config/wezterm/))
* [Alacritty](https://alacritty.org) ([config](./.config/alacritty/))
* [Tmux](https://github.com/tmux/tmux) ([config](./.tmux.conf))
* [fzf](https://github.com/junegunn/fzf) ([config](./.config/fzf/))

### Shell

* [Zsh](https://www.zsh.org) ([config](./.config/zsh/))
  * Use [Zimfw](https://zimfw.sh) framework
  * Prompt powered by [Starship](https://starship.rs/)

### File Management

* [lf](https://pkg.go.dev/github.com/gokcehan/lf) ([config](./.config/lf/))
* [Vifm](https://vifm.info) ([config](./.config/vifm/))
* [Ranger](https://ranger.github.io) ([config](./.config/ranger/))

### macOS

* [yabai](https://github.com/koekeishiya/yabai) ([config](./.config/yabai/))
* [skhd](https://github.com/koekeishiya/skhd) ([config](./.config/yabai/))
* [Sketchybar](https://github.com/FelixKratz/SketchyBar) ([config](./.config/sketchybar))
* [Karabiner-Elements](https://karabiner-elements.pqrs.org) ([config](./.config/karabiner/))

### Misc

* My scripts: [bin](./.config/bin/)

# Dotfile Management

Using a bare repository. The dotfiles can reside where they are. No symlinks needed.

## Initial setup

Create a bare repository to store the history:

```bash
git init --bare $HOME/dotfiles
```

Create an alias in zshrc, tell Git where the history and the working tree live:

```bash
alias dot='git --git-dir=$HOME/dotfiles/ --work-tree=$HOME'
```

Tell Git not to show all the untracked files, otherwise all files under `$HOME` will be shown when running `git status`:

```bash
dot config status.showUntrackedFiles no
```

Set up the remote repository for syncing:

```bash
dot remote add origin https://github.com/rockyzhang24/dotfiles.git
```

Done! Now we can manage our dotfiles.

```bash
dot status
dot add ~/.config/zsh
dot commit -m "update zsh config"
dot push origin master
```

## Clone to another machine

Clone the dotfiles into a bare repository:

```bash
git clone --bare https://github.com/rockyzhang24/dotfiles.git $HOME/dotfiles
```

Define the alias in the current shell scope:

```bash
alias dot='git --git-dir=$HOME/dotfiles/ --work-tree=$HOME'
```

Backup the stock configuration files that will be overwritten:

```bash
mkdir -p .config-backup
dot checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .config-backup/{}
```

Checkout the actual content from the bare repository to `$HOME`:

```bash
dot checkout
```

Don't show untracked files and directories:

```bash
dot config status.showUntrackedFiles no
```

Done!

## Notes

In order for [vim-fugitive](https://github.com/tpope/vim-fugitive) to recognize this bare repo, the following additional configurations are required:

```bash
dot config core.bare 'false'
dot config core.worktree "$HOME"
```
