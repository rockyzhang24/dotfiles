#!/usr/bin/env bash

if [[ $(file -b "$1") == directory ]]; then
  tree -C "$1"
  exit
fi

mime=$(file --dereference --brief --mime-type "$1")

if [[ $mime =~ \-binary ]]; then
  file "$1"
  exit
fi

# In kitty, preview image via kitty image protocal. Introduced since fzf 0.43.0. It works in the
# normal terminal and tmux but not in Neovim's builtin term.
# Use file command as the fallback. It outputs the file properties, separated by comma, in a single
# lone line. In order to fit the width of the preview window, replace each comma with a line break,
# but leave the commas inside square brackets unchanged.
if [[ $mime =~ image/ ]]; then
  if [[ -n $KITTY_WINDOW_ID && -z $NVIM ]]; then
    # --transfer-mode=memory is the fastest option but if you want fzf to be able to redraw the image
    # on terminal resize or on 'change-preview-window', you need to use --transfer-mode=stream.
    kitty icat --clear --transfer-mode=memory --unicode-placeholder --stdin=no --align left --place=${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}@0x0 "$1" | sed '$d' | sed $'$s/$/\e[m/'
  else
    file "$1" | gsed -r ':a; s/(\[[^][]*),([^][]*\])/\1TTEEMMPP\2/g; ta; s/, /\n/g; s/TTEEMMPP/,/g'
  fi
  exit
fi
# Video can be previewed by previewing its thumbnail
if [[ $mime =~ video/|audio/ ]]; then
  if [[ -n $KITTY_WINDOW_ID && -z $NVIM ]]; then
    thumbnail=$($HOME/.config/lf/vidthumb "$1")
    kitty icat --clear --transfer-mode=memory --unicode-placeholder --stdin=no --align left --place=${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}@0x0 "$thumbnail" | sed '$d' | sed $'$s/$/\e[m/'
  else
    file "$1" | gsed -r ':a; s/(\[[^][]*),([^][]*\])/\1TTEEMMPP\2/g; ta; s/, /\n/g; s/TTEEMMPP/,/g'
  fi
  exit
fi

(bat --color=always --style=numbers "$1" \
  || highlight --out-format truecolor --style darkplus --force --line-numbers "$1" \
  || cat "$1") | head -200 \
  || echo -e " No preview supported for the current selection:\n\n $1"
