source ~/.config/zsh/prompt # Powerlevel10k, should be at the top of zshrc

source ~/.config/zsh/general
source ~/.config/zsh/env
source ~/.config/zsh/aliases
source ~/.config/zsh/plugins
source ~/.config/zsh/completion
source ~/.config/zsh/keybindings

source ~/.config/fzf/fzf

# Use lf to switch directories and bind it to ctrl-o
# source ~/.config/lf/lfcd

# python3 virtual environment (virtualenv)
source /usr/local/bin/virtualenvwrapper.sh

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/yanzhang/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/yanzhang/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/yanzhang/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/yanzhang/google-cloud-sdk/completion.zsh.inc'; fi
