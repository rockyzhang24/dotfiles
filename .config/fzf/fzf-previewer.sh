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
if [[ $mime =~ image/ ]]; then
  echo "Resolution: $(identify -format "%w×%h" "$1")"
  if [[ -n $KITTY_WINDOW_ID && -z $NVIM ]]; then
    # --transfer-mode=memory is the fastest option but if you want fzf to be able to redraw the image
    # on terminal resize or on 'change-preview-window', you need to use --transfer-mode=stream.
    kitty icat --clear --transfer-mode=memory --unicode-placeholder --stdin=no --align left --place="${FZF_PREVIEW_COLUMNS}x$(( FZF_PREVIEW_LINES - 1 ))"@0x0 "$1" | sed '$d' | sed $'$s/$/\e[m/'
  else
    echo "Image preview is NOT supported!"
  fi
  exit
fi
# Video can be previewed by previewing its thumbnail
if [[ $mime =~ video/|audio/ ]]; then
  dimensions=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 "$1")
  echo "Dimensions: $dimensions"
  if [[ -n $KITTY_WINDOW_ID && -z $NVIM ]]; then
    thumbnail=$($HOME/.config/lf/vidthumb "$1")
    kitty icat --clear --transfer-mode=memory --unicode-placeholder --stdin=no --align left --place="${FZF_PREVIEW_COLUMNS}x$(( FZF_PREVIEW_LINES - 1))"@0x0 "$thumbnail" | sed '$d' | sed $'$s/$/\e[m/'
  else
    echo "Video preview is NOT supported!"
  fi
  exit
fi

(bat --color=always --style=numbers "$1" \
  || highlight --out-format truecolor --style darkplus --force --line-numbers "$1" \
  || cat "$1") | head -200 \
  || echo -e " No preview supported for the current selection:\n\n $1"
