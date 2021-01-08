source ~/.config/zsh/prompt # Powerlevel10k, should be at the top of zshrc

# zsh
source ~/.config/zsh/general
source ~/.config/zsh/env
source ~/.config/zsh/aliases
source ~/.config/zsh/completion
source ~/.config/zsh/vi
source ~/.config/zsh/plugins
source ~/.config/zsh/keybindings

# fzf
source ~/.config/fzf/fzf-config

# python3 virtual environment (virtualenv)
source /usr/local/bin/virtualenvwrapper.sh

# perl5
source ~/perl5/perlbrew/etc/bashrc

# lf
source $HOME/.config/lf/icons

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/yanzhang/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/yanzhang/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/yanzhang/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/yanzhang/google-cloud-sdk/completion.zsh.inc'; fi
