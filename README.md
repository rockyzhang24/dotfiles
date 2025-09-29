# .dotfiles

My dotfiles for `macOS` and `Linux`. Just cherry pick the piece of code you totally understand.

![platform](https://img.shields.io/badge/platform-macOS%2FLinux-blue)
![last commit](https://img.shields.io/github/last-commit/rockyzhang24/dotfiles)

![demo](https://github.com/user-attachments/assets/de888ec1-a391-48f2-b951-0a7dfabdbb90)

↗ Like the color theme? Please check [arctic.nvim](https://github.com/rockyzhang24/arctic.nvim).

# ✨ Contents

### 🔥 Text Editor

* [Neovim](https://neovim.io) ([config](./.config/nvim/))

### 🐚 Shell

* [Zsh](https://www.zsh.org) ([config](./.config/zsh/))

  * Use [Zimfw](https://zimfw.sh) framework
  * The prompt is [Starship](https://starship.rs/)

### 📟 Terminal Emulator

* [Ghostty](https://ghostty.org/) ([config](./.config/ghostty/))
* [Kitty](https://sw.kovidgoyal.net/kitty/) ([config](./.config/kitty/))
* [Wezterm](https://wezfurlong.org/wezterm/) ([config](./.config/wezterm/))
* [Alacritty](https://alacritty.org) ([config](./.config/alacritty/))

### 🪄 Tiling Window Manager

* [yabai](https://github.com/koekeishiya/yabai) ([config](./.config/yabai/))
* [skhd](https://github.com/koekeishiya/skhd) ([config](./.config/yabai/))

### 🗃️ Console File Manager

* [lf](https://pkg.go.dev/github.com/gokcehan/lf) ([config](./.config/lf/))
* [Vifm](https://vifm.info) ([config](./.config/vifm/))
* [Ranger](https://ranger.github.io) ([config](./.config/ranger/))

### 🪟 Menu Bar

* [Sketchybar](https://github.com/FelixKratz/SketchyBar) ([config](./.config/sketchybar))

### ⌨️ Keyboard Customizer

* [Karabiner-Elements](https://karabiner-elements.pqrs.org) ([config](./.config/karabiner/))

### 🧶 Others

* [Tmux](https://github.com/tmux/tmux) ([config](./.tmux.conf))
* [fzf](https://github.com/junegunn/fzf) ([config](./.config/fzf/))
* My scripts: [bin](./.config/bin/)

# 💡 How I am managing the dotfiles

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
