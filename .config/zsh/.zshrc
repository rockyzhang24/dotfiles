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
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':fzf-tab:*' fzf-pad 4
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup

# Ensure add-zsh-hook is available
autoload -Uz add-zsh-hook

# History
HISTFILE="$ZDOTDIR/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY_TIME
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_EXPIRE_DUPS_FIRST

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

# uv (a python package managers used to install ZMK)
source "$HOME/.local/bin/env"

# Shortcuts functions

git() {
    case "$PWD" in
        "$HOME"|"$HOME/.config"|"$HOME/.config"/*)
            command git --git-dir="$HOME/dotfiles" --work-tree="$HOME" "$@"
            ;;
        *)
            command git "$@"
            ;;
    esac
}

..cd() {
    cd .. || return
    cd "$@"
}

_..cd() {
    _path_files -W "$PWD/.." -/
}

compdef _..cd ..cd

# Open a timestamped temporary file in Neovim with the given filetype
temp() {
    nvim +"set filetype=$1" "/tmp/temp-$(date +'%Y%m%d-%H%M%S')"
}

gitzip() {
    git archive -o "$(basename "$PWD").zip" HEAD
}

gittgz() {
    git archive -o "$(basename "$PWD").tgz" HEAD
}

# Show commits in branch2 that are not in branch1
gitdiffb() {
    if [ $# -ne 2 ]; then
        echo two branch names required
        return
    fi
    git log --graph \
        --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' \
        --abbrev-commit --date=relative $1..$2
}

make-patch() {
    local prefix="$(git log --oneline -1 | awk '{print $2}' | tr '/:' '--' | sed 's/-$//')"
    local suffix=
    for i in {2..10}; do
        local name=$prefix$suffix.patch
        [ -e "$name" ] || break
        suffix=-v$i
    done
    echo $name
    git format-patch -1 --stdout > "$name"
}

# Copy stdin to the clipboard without the trailing newline
pbc() {
    perl -pe 'chomp if eof' | pbcopy
}

# Resize images to a maximum dimension of 2048px
resizes() {
    mkdir -p out &&
        for image in *.(jpg|jpeg|JPG|JPEG|png|PNG)(N); do
            echo "$image"
            [ -e "out/$image" ] || sips -Z 2048 --setProperty formatOptions 80 "$image" --out "out/$image"
        done
}

# Follow log output until a matching pattern is found
# E.g., tail-until "Server Started" app.log
tail-until() (
    pattern=$1
    shift
    grep -m 1 "$pattern" <(exec tail -F "$@"); kill $!
)

# Print the difference between two timestamps in seconds
# E.g.,
# tdiff 10:00 12:30
# tdiff 2026-06-25 2026-06-26
# tdiff "2026-06-25 10:00 UTC" "2026-06-25 10:00 PDT"
tdiff() {
    ruby -rtime -e 'puts ARGV.reverse.map { Time.parse(it) }.reduce(:-)' "$@"
}

# Print a GitHub-compare URL between two revisions.
# Defaults to HEAD@{1}..HEAD (i.e. the state before/after an amend or rebase).
# Usage: gh-compare [OLD] [NEW] [REMOTE]
gh-compare() {
    local old="${1:-HEAD@{1}}" new="${2:-HEAD}" remote="${3:-origin}"

    old=$(git rev-parse "$old") || return 1
    new=$(git rev-parse "$new") || return 1

    local url
    url=$(git remote get-url "$remote") || return 1

    url=${url%.git}

    if [[ "$url" == git@*:* ]]; then
        # git@host:owner/repo -> https://host/owner/repo
        url=${url#git@}
        url=${url/:/\/}
        url="https://$url"
    elif [[ "$url" == https://* ]]; then
        # already a https URL
        :
    elif [[ "$url" == http://* ]]; then
        # normalize http to https
        url="https://${url#http://}"
    else
        echo "unsupported remote URL: $url" >&2
        return 1
    fi

    printf '%s/compare/%s..%s\n' "$url" "$old" "$new"
}

# Read JSON from stdin and interactively develop jq expressions
# E.g., cat data.json | fjq
fjq() {
    local TEMP QUERY
    TEMP=$(mktemp -t fjq) || return
    trap 'rm -f "$TEMP"' EXIT
    cat >| "$TEMP"
    QUERY=$(
        jq -C . "$TEMP" |
            fzf --reverse --ansi --disabled \
            --prompt 'jq> ' --query '.' \
            --preview "jq -C {q} \"$TEMP\"" \
            --header 'Press CTRL-Y to copy expression to the clipboard and quit' \
            --bind 'ctrl-y:execute-silent(echo -n {q} | pbcopy)+abort' \
            --bind 'result:transform-preview-label(echo [ {q} ])+unbind(focus)' \
            --print-query | head -1
        )
        [ -n "$QUERY" ] && jq "$QUERY" "$TEMP"
}

# Cherry-pick a GitHub commit or PR from its URL, or a commit SHA.
# Examples:
#   - gh-cherry-pick https://github.com/owner/repo/commit/...
#   - gh-cherry-pick https://github.com/owner/repo/pull/123
#   - gh-cherry-pick abc1234
gh-cherry-pick() {
    local input=$1 repo sha pr

    [[ -z "$input" ]] && {
        echo "usage: gh-cherry-pick <github-commit-url|github-pr-url|sha>" >&2
            return 1
    }

    # Direct SHA: cherry-pick from current repository.
    if [[ "$input" =~ ^[0-9a-f]{7,40}$ ]]; then
        git cherry-pick "$input"
        return
    fi

    repo=$(sed -nE 's#.*github\.com/([^/]+/[^/]+).*#\1#p' <<< "$input")
    [[ -z "$repo" ]] && {
        echo "bad GitHub URL: $input" >&2
            return 1
    }

    # GitHub commit URL.
    sha=$(sed -nE 's#.*github\.com/[^/]+/[^/]+/commit/([0-9a-f]{7,40}).*#\1#p' <<< "$input")

    if [[ -n "$sha" ]]; then
        git fetch "https://github.com/${repo}.git" "$sha" &&
            git cherry-pick "$sha"
        return
    fi

    # GitHub PR URL.
    pr=$(sed -nE 's#.*github\.com/[^/]+/[^/]+/pull/([0-9]+).*#\1#p' <<< "$input")

    if [[ -n "$pr" ]]; then
        git fetch "https://github.com/${repo}.git" "pull/${pr}/head" &&
            git cherry-pick FETCH_HEAD
        return
    fi

    echo "unsupported GitHub URL: $input" >&2
    return 1
}

# Change to the nearest ancestor directory whose name contains the argument (e.g. `bd l` -> `lua`).
bd() {
    local dir="${PWD:h}"

    while [[ "$dir" != / ]]; do
        if [[ "${dir:t}" == *"$1"* ]]; then
            cd "$dir"
            return
        fi
        dir="${dir:h}"
    done

    print -u2 "bd: no ancestor directory matching: $1"
    return 1
}
