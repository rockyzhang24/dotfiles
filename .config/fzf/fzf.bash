# Setup fzf
# ---------
if [[ ! "$PATH" == */Users/rockyzhang/gitrepos/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/Users/rockyzhang/gitrepos/fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/Users/rockyzhang/gitrepos/fzf/shell/completion.bash" 2> /dev/null

# Key bindings
# ------------
source "/Users/rockyzhang/gitrepos/fzf/shell/key-bindings.bash"
