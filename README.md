<div align="center">
  
# .dotfiles

My dotfiles for `macOS` and `Linux`. Just cherry pick the piece of code you totally understand.

![platform](https://img.shields.io/badge/platform-macOS%2FLinux-blue)
![last commit](https://img.shields.io/github/last-commit/rockyzhang24/dotfiles)

<img width="1728" alt="image" src="https://user-images.githubusercontent.com/11582667/156706194-0762c4d8-b6e3-403c-929d-b49de198e30d.png">

</div>
  
# Features

[Neovim](./.config/nvim/): The text editor I've been in love with

[Zsh](./.config/zsh/): Shell

* Use [Zim](https://github.com/zimfw/zimfw) to manage Zsh plugins
* The prompt theme is [Powerlevel10k](https://github.com/romkatv/powerlevel10k[])
* [fzf](./.config/fzf): Fuzzy finder I use widely in my daily workflow. I created some fzf-based [scripts](./.config/fzf/fzfutils/) to boost productivity
* [bin](./.config/bin): Very useful scripts

[kitty](./.config/kitty/)/[alacritty](./.config/alacritty/): Terminal

[yabai](./.config/yabai/) and [skhd](./.config/skhd/): Tiling window manager

[lf](./.config/lf/)/[vifm](./.config/vifm/)/[ranger](./.config/ranger/): Console file manager

[karabiner-Elements](./.config/karabiner/): keyboard customizer

* `Caps Lock` as `Esc` and `L-Ctrl`
* `R-Command` as `HYPER` key
* `L-Ctrl` as `MEH` key

# How I am managing the dotfiles

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
