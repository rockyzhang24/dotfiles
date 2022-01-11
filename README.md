# My config files ...

These are my config files on macOS.

Settings for:
* [Neovim](./.config/nvim/) (my life)
* [Zsh](./.config/zsh/) (shell)
* [yabai](./.config/yabai/) & [skhd](./.config/skhd/) (window manager)
* [lf](./.config/lf/)/[vifm](./.config/vifm/)/[ranger](./.config/ranger/) (file manager)
* [kitty](./.config/kitty/)/[alacritty](./.config/alacritty/)/iTerm2 (terminal)
* [karabiner](./.config/karabiner/) (keyboard customizer)

# How I am managing the dotfiles

Using a bare Git repo. The dotfiles can reside where they are. No symlinks needed.

## Initial setup

Create a bare Git repo to store the history.

```bash
git init --bare $HOME/dotfiles
```

Create an alias in zshrc, tell Git where the history and the working tree (snapshot) live.

```bash
alias cfg='git --git-dir=$HOME/dotfiles/ --work-tree=$HOME'
```

Tell Git not to show all the untracked files (otherwise all files under $HOME will be shown when running `git status`.

```bash
cfg config status.showUntrackedFiles no
```

Set up the remote repo to sync

```bash
cfg remote add origin https://github.com/yanzhang0219/dotfiles.git
```

Done! Now we can manage our dotfiles.

```bash
cfg status
cfg add ~/.config/zsh
cfg commit -m "zsh config"
cfg push origin master
```

## Clone to another machine

Clone this repo onto a new machine as a non-bare repo because we need the actual dotfiles that is the working tree, i.e., the snapshot of the repo.

```bash
git clone --separate-git-dir=$HOME/dotfiles https://github.com/yanzhang0219/dotfiles.git dotfiles-temp
```

Copy the dotfiles to the location where they should reside.

```bash
rsync --recursive --verbose --exclude '.git' dotfiles-temp/ $HOME/
```

Remove the temp directory.

```bash
trash dotfiles-temp
```

Tell Git not to show all the untracked files.

```bash
cfg config status.showUntrackedFiles no
```

Finally, set up your own remote repo for syncing.

```bash
cfg remote add origin https://github.com/xxxx/dotfiles.git
```

Done! Now, start to manage your dotfiles.
