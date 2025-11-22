# Completion for other programs
fpath=($ZDOTDIR/completions/ $fpath)

# My own defined autoload functions under ~/.config/zsh/functions/
autoload_functions_dir="$ZDOTDIR/functions"
fpath+=$autoload_functions_dir
autoload -Uz ${autoload_functions_dir}/*(.:t)

# Uncomment lines below if not using the completion module in Zimfw
# autoload -Uz compinit
# compinit

# Zimfw
if [[ ${ZIM_HOME}/init.zsh -ot ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
    source ${ZIM_HOME}/zimfw.zsh init -q
fi
source ${ZIM_HOME}/init.zsh

# The prefix for the alias from zim builtin git module
#zstyle ':zim:git' aliases-prefix 'g'

# Append `../` to your input for each `.` you type after an initial `..`
zstyle ':zim:input' double-dot-expand yes

# zsh-syntax-highlighting
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# fzf-tab
zstyle ':fzf-tab:*' fzf-flags '--preview-window=hidden,<9999(hidden)'
zstyle ':fzf-tab:*' fzf-preview 'echo Preview is not available!'
zstyle ':fzf-tab:*' fzf-pad 4

# Ensure add-zsh-hook is available
autoload -Uz add-zsh-hook

# Remove duplicated commands in history
setopt HIST_IGNORE_ALL_DUPS

# Make right prompt aligned to the rightmost
ZLE_RPROMPT_INDENT=0

# Change open files limit on macOS
ulimit -n 524288
ulimit -u 2048

# Use menu selection for completion
zstyle ':completion:*' menu select
zmodload zsh/complist

# Include hidden files in autocomplete
_comp_options+=(globdots)

# Completion for other programs
fpath=($ZDOTDIR/completions/ $fpath)

# For kitty kitten: hyperlinked grep (defined in ~/.config/zsh/functions/hg)
# Delegate its completion to rg
compdef _rg hg

# Make ngl (~/.config/zsh/functions/ngl) support autocomplete as `git log`
compdef _ngl ngl
_ngl() {
    (( $+functions[_git-log] )) || _git
    _git-log
}

# Make ngd (~/.config/zsh/functions/ngd) support autocomplete as `git difftool`
compdef _ngd ngd
_ngd() {
    (( $+functions[_git-difftool] )) || _git
    _git-difftool
}

# Auto-cd if the command is a directory and can't be executed as a normal command
setopt auto_cd

# When deleting with <C-w>, delete file names at a time.
WORDCHARS=${WORDCHARS/\/}

source "$ZDOTDIR/aliases"
source "$ZDOTDIR/keybindings"
# source "$ZDOTDIR/vi" # use vi mode
source "$ZDOTDIR/env"

# fzf
source "$HOME/.config/fzf/fzf-config"

# Rust
source "$HOME/.cargo/env"

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

# Emit OSC 7 upon each pwd change
# So when we change cwd in Neovim's builtin terminal, nvim's TermRequest event is triggere and we
# can change the current directory of the terminal window to the directory pointed to by the OSC 7.
function print_osc7() {
    if [ "$ZSH_SUBSHELL" -eq 0 ] ; then
        printf "\033]7;file://$HOST/$PWD\033\\"
    fi
}
autoload -Uz add-zsh-hook
add-zsh-hook -Uz chpwd print_osc7
print_osc7

# Emis OSC 133;A just before the prompt is printed
# In Neovim we use it to mark where each prompt starts
function print_osc133() {
    printf "\e]133;A\a"
}
precmd_functions+=(print_osc133)
