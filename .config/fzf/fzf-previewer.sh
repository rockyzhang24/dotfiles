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

# In kitty (for both normal terminal and tmux), preview image via kitty image protocal. Introduced
# since fzf 0.43.0.
if [[ -n $KITTY_WINDOW_ID && $mime =~ image/ ]]; then
  # --transfer-mode=memory is the fastest option but if you want fzf to be able to redraw the image
  # on terminal resize or on 'change-preview-window', you need to use --transfer-mode=stream.
  kitty icat --clear --transfer-mode=memory --unicode-placeholder --stdin=no --place=${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}@0x0 "$1" | sed '$d' | sed $'$s/$/\e[m/'
  exit
fi

(bat --color=always --style=numbers,changes,header "$1" \
  || highlight --out-format truecolor --style darkplus --force --line-numbers "$1" \
  || cat "$1") | head -200 \
  || echo -e " No preview supported for the current selection:\n\n $1"
