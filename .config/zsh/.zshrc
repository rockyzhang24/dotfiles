source ~/.config/zsh/prompt # Powerlevel10k, should be at the top of zshrc

# zsh
source ~/.config/zsh/general
source ~/.config/zsh/vi
source ~/.config/zsh/plugins
source ~/.config/zsh/completion
source ~/.config/zsh/aliases
source ~/.config/zsh/keybindings

# fzf
source ~/.config/fzf/fzf-config

# Rust
source ~/.cargo/env

# lf
source $HOME/.config/lf/icons

# Setup ls colors
source $HOME/.config/zsh/lscolors.sh

# iTerm2 Shell Integration
test -e "${ZDOTDIR}/.iterm2_shell_integration.zsh" && source "${ZDOTDIR}/.iterm2_shell_integration.zsh"
