# Setup fzf
# ---------
if [[ ! "$PATH" == */Users/yanzhang/gitrepos/fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/Users/yanzhang/gitrepos/fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/Users/yanzhang/gitrepos/fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/Users/yanzhang/gitrepos/fzf/shell/key-bindings.zsh"
