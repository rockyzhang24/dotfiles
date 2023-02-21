<div align="center">

# .dotfiles

My dotfiles for `macOS` and `Linux`. Just cherry pick the piece of code you totally understand.

![platform](https://img.shields.io/badge/platform-macOS%2FLinux-blue)
![last commit](https://img.shields.io/github/last-commit/rockyzhang24/dotfiles)
  
![config-demo](https://user-images.githubusercontent.com/11582667/220463312-8559aba9-e0d8-4bdc-8d02-3dc322204df4.png)
  <sub>For the color theme, check [arctic](https://github.com/rockyzhang24/arctic.nvim)</sub>

</div>

# ✨ Contents

### 🔥 Text Editor

#### [Neovim](https://neovim.io): [⚙️Config](./.config/nvim/)

### 🐚 Shell

#### [Zsh](https://www.zsh.org): [⚙️Config](./.config/zsh/)

### 🛠️ Terminal Emulator

#### [Kitty](https://sw.kovidgoyal.net/kitty/): [⚙️Config](./.config/kitty/)

#### [Wezterm](https://wezfurlong.org/wezterm/): [⚙️Config](./.config/wezterm/)

#### [Alacritty](https://alacritty.org): [⚙️Config](./.config/alacritty/)

### 🪄 Tiling Window Manager

#### [yabai](https://github.com/koekeishiya/yabai): [⚙️Config](./.config/yabai/)
#### [skhd](https://github.com/koekeishiya/skhd): [⚙️Config](./.config/yabai/)

### 🗃️ Console File Manager

#### [lf](https://pkg.go.dev/github.com/gokcehan/lf): [⚙️Config](./.config/lf/)

#### [vifm](https://vifm.info): [⚙️Config](./.config/vifm/)

#### [ranger](https://ranger.github.io): [⚙️Config](./.config/ranger/)

### ⌨️ Keyboard Customizer

#### [Karabiner-Elements](https://karabiner-elements.pqrs.org): [⚙️Config](./.config/karabiner/)

# 💡 How I am managing the dotfiles

Using a bare repository. The dotfiles can reside where they are. No symlinks needed.

## Initial setup

Create a bare repository to store the history.

```bash
git init --bare $HOME/dotfiles
```

Create an alias in zshrc, tell Git where the history and the working tree (snapshot) live.

```bash
alias cfg='git --git-dir=$HOME/dotfiles/ --work-tree=$HOME'
```

Tell Git not to show all the untracked files, otherwise all files under `$HOME` will be shown when running `git status`.

```bash
cfg config status.showUntrackedFiles no
```

Set up the remote repository for syncing

```bash
cfg remote add origin https://github.com/xxx/dotfiles.git
```

Done! Now we can manage our dotfiles.

```bash
cfg status
cfg add ~/.config/zsh
cfg commit -m "zsh config"
cfg push origin master
```

## Clone to another machine

Clone the dotfiles into a bare repository.

```bash
git clone --bare https://github.com/xxx/dotfiles.git $HOME/dotfiles
```

Checkout the actual content from the bare repository to `$HOME`.

```bash
git --git-dir=$HOME/dotfiles/ --work-tree=$HOME checkout
```

Done!

## Notes

If using [vim-fugitive](https://github.com/tpope/vim-fugitive) in Neovim, to make it work with this bare repo correctly, we should modify `~/dotfiles/config` as below

```
...

[core]
  bare = false
  worktree = /Users/rockyzhang/

...
```
