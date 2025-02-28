# Reference: https://github.com/junegunn/fzf-git.sh/blob/main/fzf-git.sh
# till the commit 6651e719da630cd8e6e00191af7f225f6d13a801 on 2/19/2025

# shellcheck disable=SC2039
[[ $0 = - ]] && return

__fzf_git_color() {
  if [[ -n $NO_COLOR ]]; then
    echo never
  elif [[ $# -gt 0 ]] && [[ -n $FZF_GIT_PREVIEW_COLOR ]]; then
    echo "$FZF_GIT_PREVIEW_COLOR"
  else
    echo "${FZF_GIT_COLOR:-always}"
  fi
}

__fzf_git_cat() {
  if [[ -n $FZF_GIT_CAT ]]; then
    echo "$FZF_GIT_CAT"
    return
  fi

  # Sometimes bat is installed as batcat
  _fzf_git_bat_options="--style='${BAT_STYLE:-numbers,changes,header,header-filesize}' --color=$(__fzf_git_color .) --pager=never"
  if command -v batcat > /dev/null; then
    echo "batcat $_fzf_git_bat_options"
  elif command -v bat > /dev/null; then
    echo "bat $_fzf_git_bat_options"
  else
    echo cat
  fi
}

__fzf_git_pager() {
  local pager
  pager="${FZF_GIT_PAGER:-${GIT_PAGER:-$(git config --get core.pager 2>/dev/null)}}"
  echo "${pager:-cat}"
}

if [[ $1 = --list ]]; then
  shift
  if [[ $# -eq 1 ]]; then
    branches() {
      git branch "$@" --sort=-committerdate --sort=-HEAD --format=$'%(HEAD) %(color:yellow)%(refname:short) %(color:green)(%(committerdate:relative))\t%(color:blue)%(subject)%(color:reset)' --color=$(__fzf_git_color) | column -ts$'\t'
    }
    refs() {
      git for-each-ref "$@" --sort=-creatordate --sort=-HEAD --color=$(__fzf_git_color) --format=$'%(if:equals=refs/remotes)%(refname:rstrip=-2)%(then)%(color:magenta)remote-branch%(else)%(if:equals=refs/heads)%(refname:rstrip=-2)%(then)%(color:brightgreen)branch%(else)%(if:equals=refs/tags)%(refname:rstrip=-2)%(then)%(color:brightcyan)tag%(else)%(if:equals=refs/stash)%(refname:rstrip=-2)%(then)%(color:brightred)stash%(else)%(color:white)%(refname:rstrip=-2)%(end)%(end)%(end)%(end)\t%(color:yellow)%(refname:short) %(color:green)(%(creatordate:relative))\t%(color:blue)%(subject)%(color:reset)' | column -ts$'\t'
    }
    hashes() {
      git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=$(__fzf_git_color) "$@" $LIST_OPTS
    }
    case "$1" in
      branches)
        echo ':: CTRL-O (open in browser), ALT-A (show all branches)'
        echo ':: ALT-H (list commit hashes)'
        branches
        ;;
      all-branches)
        echo ':: CTRL-O (open in browser), ALT-ENTER (accept without remote)'
        echo ':: ALT-H (list commit hashes)'
        branches -a
        ;;
      hashes)
        echo ':: CTRL-O (open in browser), CTRL-D (diff)'
        echo ':: CTRL-S (toggle sort), ALT-A (show all hashes)'
        hashes
        ;;
      all-hashes)
        echo ':: CTRL-O (open in browser), CTRL-D (diff)'
        echo ':: CTRL-S (toggle sort)'
        hashes --all
        ;;
      refs)
        echo ':: CTRL-O (open in browser), ALT-E (examine in editor), ALT-A (show all refs)'
        refs --exclude='refs/remotes'
        ;;
      all-refs)
        echo ':: CTRL-O (open in browser), ALT-E (examine in editor)'
        refs
        ;;
      nobeep) ;;
      *) exit 1 ;;
    esac
  elif [[ $# -gt 1 ]]; then
    set -e

    branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
    if [[ $branch = HEAD ]]; then
      branch=$(git describe --exact-match --tags 2> /dev/null || git rev-parse --short HEAD)
    fi

    # Only supports GitHub for now
    case "$1" in
      commit)
        hash=$(grep -o "[a-f0-9]\{7,\}" <<< "$2")
        path=/commit/$hash
        ;;
      branch|remote-branch)
        branch=$(sed 's/^[* ]*//' <<< "$2" | cut -d' ' -f1)
        remote=$(git config branch."${branch}".remote || echo 'origin')
        branch=${branch#$remote/}
        path=/tree/$branch
        ;;
      remote)
        remote=$2
        path=/tree/$branch
        ;;
      file) path=/blob/$branch/$(git rev-parse --show-prefix)$2 ;;
      tag)  path=/releases/tag/$2 ;;
      *)    exit 1 ;;
    esac

    remote=${remote:-$(git config branch."${branch}".remote || echo 'origin')}
    remote_url=$(git remote get-url "$remote" 2> /dev/null || echo "$remote")

    if [[ $remote_url =~ ^git@ ]]; then
      url=${remote_url%.git}
      url=${url#git@}
      url=https://${url/://}
    elif [[ $remote_url =~ ^http ]]; then
      url=${remote_url%.git}
    fi

    case "$(uname -s)" in
      Darwin) open "$url$path"     ;;
      *)      xdg-open "$url$path" ;;
    esac
    exit 0
  fi
fi

if [[ $- =~ i ]] || [[ $1 = --run ]]; then # ----------------------------------

# Redefine this function to change the options
_fzf_git_fzf() {
  fzf --multi \
    --min-height=20 \
    --color='header:underline' \
    --preview-window='nohidden,right,60%' \
    --bind='ctrl-/:change-preview-window(down,45%|hidden|)' "$@"

  # fzf --height 50% --tmux 90%,70% \
  #   --layout reverse --multi --min-height 20+ --border \
  #   --no-separator --header-border horizontal \
  #   --border-label-pos 2 \
  #   --color 'label:blue' \
  #   --preview-window 'right,50%' --preview-border line \
  #   --bind 'ctrl-/:change-preview-window(down,50%|hidden|)' "$@"
}

# Check git repository
_fzf_git_check() {
  # Handle the bare repo that manages my dotfiles
  if [[ $PWD == $HOME/.config || $PWD == $HOME/.config/* && $PWD != $HOME/.config/nvim/pack* ]]; then
    export GIT_DIR=$HOME/dotfiles
    export GIT_WORK_TREE=$HOME
  fi
  git rev-parse HEAD > /dev/null 2>&1 && return
  [[ -n $TMUX ]] && tmux display-message "Not in a git repository"
  return 1
}

# Assign BASH_SOURCE[0] (i.e., this script itself) to __fzf_git
__fzf_git=${BASH_SOURCE[0]:-${(%):-%x}}
__fzf_git=$(readlink -f "$__fzf_git" 2> /dev/null || /usr/bin/ruby --disable-gems -e 'puts File.expand_path(ARGV.first)' "$__fzf_git" 2> /dev/null)

# Files
_fzf_git_files() {
  _fzf_git_check || return
  local root query
  root=$(git rev-parse --show-toplevel)
  [[ $root != "$PWD" ]] && query='!../ '

  (git -c color.status=$(__fzf_git_color) status --short --no-branch
   git ls-files "$root" | grep -vxFf <(git status -s | grep '^[^?]' | cut -c4-; echo :) | sed 's/^/   /') |
  _fzf_git_fzf -m --ansi --nth 2..,.. \
    --prompt '📁 Files> ' \
    --header ':: CTRL-O (open in browser), ALT-E (open in editor)' \
    --bind "ctrl-o:execute-silent:bash \"$__fzf_git\" --list file {-1}" \
    --bind "alt-e:execute:${EDITOR:-vim} {-1} > /dev/tty" \
    --query "$query" \
    --preview "git diff --no-ext-diff --color=$(__fzf_git_color .) -- {-1} | $(__fzf_git_pager); $(__fzf_git_cat) {-1}" "$@" |
  cut -c4- | sed 's/.* -> //'
}

# Branches
_fzf_git_branches() {
  _fzf_git_check || return
  bash "$__fzf_git" --list branches |
  _fzf_git_fzf --ansi \
    --prompt '🌲 Branches> ' \
    --header-lines 2 \
    --tiebreak begin \
    --preview-window down,40% \
    --no-hscroll \
    --bind 'ctrl-/:change-preview-window(down,70%|hidden|)' \
    --bind "ctrl-o:execute-silent:bash \"$__fzf_git\" --list branch {}" \
    --bind "alt-a:change-prompt(🌳 All branches> )+reload:bash \"$__fzf_git\" --list all-branches" \
    --bind "alt-h:become:LIST_OPTS=\$(cut -c3- <<< {} | cut -d' ' -f1) bash \"$__fzf_git\" --run hashes" \
    --bind "alt-enter:become:printf '%s\n' {+} | cut -c3- | sed 's@[^/]*/@@'" \
    --preview "git log --oneline --graph --date=short --color=$(__fzf_git_color .) --pretty='format:%C(auto)%cd %h%d %s' \$(cut -c3- <<< {} | cut -d' ' -f1) --" "$@" |
  sed 's/^\* //' | awk '{print $1}' # Slightly modified to work with hashes as well
}

# Tags
_fzf_git_tags() {
  _fzf_git_check || return
  git tag --sort -version:refname |
  _fzf_git_fzf --preview-window right,70% \
    --prompt '📛 Tags> ' \
    --header ':: CTRL-O (open in browser)' \
    --bind "ctrl-o:execute-silent:bash \"$__fzf_git\" --list tag {}" \
    --preview "git show --color=$(__fzf_git_color .) {} | $(__fzf_git_pager)" "$@"
}

# Hashes
_fzf_git_hashes() {
  _fzf_git_check || return
  bash "$__fzf_git" --list hashes |
  _fzf_git_fzf --ansi --no-sort --bind 'ctrl-s:toggle-sort' \
    --prompt '🍡 Hashes> ' \
    --header-lines 2 \
    --bind "ctrl-o:execute-silent:bash \"$__fzf_git\" --list commit {}" \
    --bind "ctrl-d:execute:grep -o '[a-f0-9]\{7,\}' <<< {} | head -n 1 | xargs git diff --color=$(__fzf_git_color) > /dev/tty" \
    --bind "alt-a:change-prompt(🍇 All hashes> )+reload:bash \"$__fzf_git\" --list all-hashes" \
    --color hl:underline,hl+:underline \
    --preview "grep -o '[a-f0-9]\{7,\}' <<< {} | head -n 1 | xargs git show --color=$(__fzf_git_color .) | $(__fzf_git_pager)" "$@" |
  awk 'match($0, /[a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9]*/) { print substr($0, RSTART, RLENGTH) }'
}

# Remotes
_fzf_git_remotes() {
  _fzf_git_check || return
  git remote -v | awk '{print $1 "\t" $2}' | uniq |
  _fzf_git_fzf --tac \
    --prompt '📡 Remotes> ' \
    --header ':: CTRL-O (open in browser)' \
    --bind "ctrl-o:execute-silent:bash \"$__fzf_git\" --list remote {1}" \
    --preview-window right,70% \
    --preview "git log --oneline --graph --date=short --color=$(__fzf_git_color .) --pretty='format:%C(auto)%cd %h%d %s' '{1}/$(git rev-parse --abbrev-ref HEAD)' --" "$@" |
  cut -d$'\t' -f1
}

# Stashes
_fzf_git_stashes() {
  _fzf_git_check || return
  git stash list | _fzf_git_fzf \
    --prompt '🥡 Stashes> ' \
    --header ':: CTRL-X (drop stash)' \
    --bind 'ctrl-x:reload(git stash drop -q {1}; git stash list)' \
    -d: --preview "git show --color=$(__fzf_git_color .) {1} | $(__fzf_git_pager)" "$@" |
  cut -d: -f1
}

# Reflogs
_fzf_git_lreflogs() {
  _fzf_git_check || return
  git reflog --color=$(__fzf_git_color) --format="%C(blue)%gD %C(yellow)%h%C(auto)%d %gs" | _fzf_git_fzf --ansi \
    --prompt '📒 Reflogs> ' \
    --preview "git show --color=$(__fzf_git_color .) {1} | $(__fzf_git_pager)" "$@" |
  awk '{print $1}'
}

# Each ref
_fzf_git_each_ref() {
  _fzf_git_check || return
  bash "$__fzf_git" --list refs | _fzf_git_fzf --ansi \
    --nth 2,2.. \
    --tiebreak begin \
    --prompt '☘️ Each ref> ' \
    --header-lines 1 \
    --preview-window down,40% \
    --no-hscroll \
    --bind 'ctrl-/:change-preview-window(down,70%|hidden|)' \
    --bind "ctrl-o:execute-silent:bash \"$__fzf_git\" --list {1} {2}" \
    --bind "alt-e:execute:${EDITOR:-vim} <(git show {2}) > /dev/tty" \
    --bind "alt-a:change-prompt(🍀 Every ref> )+reload:bash \"$__fzf_git\" --list all-refs" \
    --preview "git log --oneline --graph --date=short --color=$(__fzf_git_color .) --pretty='format:%C(auto)%cd %h%d %s' {2} --" "$@" |
  awk '{print $2}'
}

# Worktrees
_fzf_git_worktrees() {
  _fzf_git_check || return
  git worktree list | _fzf_git_fzf \
    --prompt '🌴 Worktrees> ' \
    --header ':: CTRL-X (remove worktree)' \
    --bind 'ctrl-x:reload(git worktree remove {1} > /dev/null; git worktree list)' \
    --preview "
      git -c color.status=$(__fzf_git_color .) -C {1} status --short --branch
      echo
      git log --oneline --graph --date=short --color=$(__fzf_git_color .) --pretty='format:%C(auto)%cd %h%d %s' {2} --
    " "$@" |
  awk '{print $1}'
}
fi # --------------------------------------------------------------------------

if [[ $1 = --run ]]; then
  shift
  type=$1
  shift
  eval "_fzf_git_$type" "$@"

elif [[ $- =~ i ]]; then # ------------------------------------------------------

# Setup key bindings:
# CTRL-G F for files
# CTRL-G B for branches
# CTRL-G T for tags
# CTRL-G R for remotes
# CTRL-G H for commit hashes
# CTRL-G S for stashes
# CTRL-G L for Reflogs
# CTRL-G E for Each ref (git for-each-ref)
# CTRL-G W for Worktrees

if [[ -n "${BASH_VERSION:-}" ]]; then
  __fzf_git_init() {
    bind -m emacs-standard '"\er":  redraw-current-line'
    bind -m emacs-standard '"\C-z": vi-editing-mode'
    bind -m vi-command     '"\C-z": emacs-editing-mode'
    bind -m vi-insert      '"\C-z": emacs-editing-mode'

    local o c
    for o in "$@"; do
      c=${o:0:1}
      # bind -m emacs-standard '"\C-g\C-'$c'": " \C-u \C-a\C-k`_fzf_git_'$o'`\e\C-e\C-y\C-a\C-y\ey\C-h\C-e\er \C-h"'
      # bind -m vi-command     '"\C-g\C-'$c'": "\C-z\C-g\C-'$c'\C-z"'
      # bind -m vi-insert      '"\C-g\C-'$c'": "\C-z\C-g\C-'$c'\C-z"'
      bind -m emacs-standard '"\C-g'$c'":    " \C-u \C-a\C-k`_fzf_git_'$o'`\e\C-e\C-y\C-a\C-y\ey\C-h\C-e\er \C-h"'
      bind -m vi-command     '"\C-g'$c'":    "\C-z\C-g'$c'\C-z"'
      bind -m vi-insert      '"\C-g'$c'":    "\C-z\C-g'$c'\C-z"'
    done
  }
elif [[ -n "${ZSH_VERSION:-}" ]]; then
  __fzf_git_join() {
    local item
    while read item; do
      echo -n "${(q)item} "
    done
  }

  __fzf_git_init() {
    bindkey -r '^g'
    local m o
    for o in "$@"; do
      eval "fzf-git-$o-widget() { local result=\$(_fzf_git_$o | __fzf_git_join); zle reset-prompt; LBUFFER+=\$result }"
      eval "zle -N fzf-git-$o-widget"
      for m in emacs vicmd viins; do
        # eval "bindkey -M $m '^g^${o[1]}' fzf-git-$o-widget"
        eval "bindkey -M $m '^g${o[1]}' fzf-git-$o-widget"
      done
    done
  }
fi
__fzf_git_init files branches tags remotes hashes stashes lreflogs each_ref worktrees

fi # --------------------------------------------------------------------------
