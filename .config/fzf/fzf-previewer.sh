#!/usr/bin/env bash

path="${1/#\~/$HOME}"

if [[ $(file -b "$path") == directory ]]; then
  tree -C "$path"
  exit
fi

mime=$(file --dereference --brief --mime-type "$path")

if [[ $mime =~ \-binary ]]; then
  file "$path"
  exit
fi

# In kitty, preview image via kitty image protocal. Introduced since fzf 0.43.0. It works in the
# normal terminal and tmux but not in Neovim's builtin term.
if [[ $mime =~ image/ ]]; then
  echo "Resolution: $(identify -format "%w×%h" "$path")"
  if [[ -n $KITTY_WINDOW_ID && -z $NVIM ]]; then
    # --transfer-mode=memory is the fastest option but if you want fzf to be able to redraw the image
    # on terminal resize or on 'change-preview-window', you need to use --transfer-mode=stream.
    kitty icat --clear --transfer-mode=memory --unicode-placeholder --stdin=no --align left --place="${FZF_PREVIEW_COLUMNS}x$(( FZF_PREVIEW_LINES - 1 ))"@0x0 "$path" | sed '$d' | sed $'$s/$/\e[m/'
  else
    echo "Image preview is NOT supported!"
  fi
  exit
fi
# Video can be previewed by previewing its thumbnail
if [[ $mime =~ video/|audio/ ]]; then
  dimensions=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 "$path")
  echo "Dimensions: $dimensions"
  if [[ -n $KITTY_WINDOW_ID && -z $NVIM ]]; then
    thumbnail=$("$HOME"/.config/lf/vidthumb "$path")
    kitty icat --clear --transfer-mode=memory --unicode-placeholder --stdin=no --align left --place="${FZF_PREVIEW_COLUMNS}x$(( FZF_PREVIEW_LINES - 1))"@0x0 "$thumbnail" | sed '$d' | sed $'$s/$/\e[m/'
  else
    echo "Video preview is NOT supported!"
  fi
  exit
fi

(bat --color=always --style=numbers "$path" \
  || highlight --out-format truecolor --style darkplus --force --line-numbers "$path" \
  || cat "$path") | head -200 \
  || echo -e " No preview supported for the current selection:\n\n $path"
