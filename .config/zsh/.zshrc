# zsh
source $HOME/.config/zsh/plugins
source $HOME/.config/zsh/general
source $HOME/.config/zsh/completion
source $HOME/.config/zsh/aliases
source $HOME/.config/zsh/keybindings
# source $HOME/.config/zsh/vi # use vi mode
source $HOME/.config/zsh/env

# fzf
source $HOME/.config/fzf/fzf-config

# Rust
source $HOME/.cargo/env

# iTerm2 Shell Integration
export ITERM2_SQUELCH_MARK=1
test -e "${ZDOTDIR}/iterm2_shell_integration.zsh" && source "${ZDOTDIR}/iterm2_shell_integration.zsh"

# Wezterm Shell Integration
[[ -n $WEZTERM_CONFIG_DIR ]] && test -e "${ZDOTDIR}/wezterm_shell_integration.sh" && source "${ZDOTDIR}/wezterm_shell_integration.sh"

# zoxide
source $HOME/.config/zoxide/zoxide-config
eval "$(zoxide init zsh)"

# Starship
eval "$(starship init zsh)"
