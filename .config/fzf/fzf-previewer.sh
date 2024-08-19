#!/usr/bin/env bash

file="${1/#\~/$HOME}"

if [[ $(file -b "$file") == directory ]]; then
  tree -C "$file"
  exit
fi

mime=$(file --dereference --brief --mime-type "$file")

if [[ $mime =~ \-binary ]]; then
  file "$file"
  exit
fi

image_previewer() {
  if [[ -n $KITTY_WINDOW_ID ]]; then
    # In Kitty
    # Kitty image protocal works well in both normal terminal and tmux, but not in Neovim's builtin
    # terminal. Tmux is special, it works in tmux pane but fails in tmux popup (ref:
    # https://github.com/junegunn/fzf/issues/3972). My fzf starts in tmux popup when it runs in
    # tmux, so kitty image protocal does not work. In all the situations where kitty image protocal
    # fails to work, use chafa with symbol (ANSI art) format as a workaround.
    if [[ ! $TERM =~ "tmux" && -z $NVIM ]]; then
      # --transfer-mode=memory is the fastest option but if you want fzf to be able to redraw the image
      # on terminal resize or on 'change-preview-window', you need to use --transfer-mode=stream.
      kitty icat --clear --transfer-mode=memory --unicode-placeholder --stdin=no --align left --place="${FZF_PREVIEW_COLUMNS}x$((FZF_PREVIEW_LINES - 1))"@0x0 "$1" | sed '$d' | sed $'$s/$/\e[m/'
    else
      chafa -f symbols -s "${FZF_PREVIEW_COLUMNS}x$((FZF_PREVIEW_LINES - 1))" --animate off --polite on "$1"
    fi
  elif [[ $WEZTERM_PANE || $ALACRITTY_WINDOW_ID ]]; then
    # In Wezterm or Alacritty
    if [[ -z $NVIM ]]; then
      chafa -s "${FZF_PREVIEW_COLUMNS}x$((FZF_PREVIEW_LINES - 1))" --animate off --polite on "$1"
    else
      chafa -f symbols -s "${FZF_PREVIEW_COLUMNS}x$((FZF_PREVIEW_LINES - 1))" --animate off --polite on "$1"
    fi
  else
    echo "Image preview is NOT supported!"
  fi
}

if [[ $mime =~ image/ ]]; then
  echo "Resolution: $(identify -format "%w×%h" "$file")"
  image_previewer "$file"
  exit
fi
# Video can be previewed by previewing its thumbnail
if [[ $mime =~ video/|audio/ ]]; then
  dimensions=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 "$file")
  echo "Dimensions: $dimensions"
  thumbnail=$("$HOME"/.config/lf/vidthumb "$file")
  image_previewer "$thumbnail"
  exit
fi

(bat --color=always --style=numbers "$file" \
  || highlight --out-format truecolor --style darkplus --force --line-numbers "$file" \
  || cat "$file") | head -200 \
  || echo -e " No preview supported for the current selection:\n\n $file"
