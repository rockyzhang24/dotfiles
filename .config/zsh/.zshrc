# Enable powerlevel10k instant prompt (should stay at the top)
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ========
# General
# ========

# Remove duplicated commands in history
setopt HIST_IGNORE_ALL_DUPS

# Prompt for spelling correction of commands.
setopt CORRECT

# Use menu selection for completion
zstyle ':completion:*' menu select
zmodload zsh/complist

# ========
# zimfw
# ========

if [[ ${ZIM_HOME}/init.zsh -ot ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
  source ${ZIM_HOME}/zimfw.zsh init -q
fi
source ${ZIM_HOME}/init.zsh

# The prefix for the alias from zim builtin git module
#zstyle ':zim:git' aliases-prefix 'g'

# Append `../` to your input for each `.` you type after an initial `..`
zstyle ':zim:input' double-dot-expand yes

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# ========
# Other zsh settings
# ========

source ~/.config/zsh/vi
source ~/.config/zsh/aliases

# ========
# Other programe settings
# ========

source ~/.config/zsh/fzf
source ~/.config/z/z.sh

# Use lf to switch directories and bind it to ctrl-o
# source ~/.config/lf/lfcd

# python3 virtual environment (virtualenv)
source /usr/local/bin/virtualenvwrapper.sh

# Updates PATH for the Google Cloud SDK.
[ -f '/Users/yanzhang/Downloads/google-cloud-sdk/path.zsh.inc' ] && source '/Users/yanzhang/Downloads/google-cloud-sdk/path.zsh.inc'

# Enables shell command completion for gcloud.
[ -f '/Users/yanzhang/Downloads/google-cloud-sdk/completion.zsh.inc' ] && source '/Users/yanzhang/Downloads/google-cloud-sdk/completion.zsh.inc'

# Use Powerlevel10k prompt theme
source ~/gitrepos/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh

# ========
# Completion (loading plugins before this)
# ========

autoload -Uz compinit
compinit

# Include hidden files in autocomplete
_comp_options+=(globdots)

# Completion for kitty
kitty + complete setup zsh | source /dev/stdin

# Completion for other programs
fpath=($HOME/.config/zsh/completions $fpath)
