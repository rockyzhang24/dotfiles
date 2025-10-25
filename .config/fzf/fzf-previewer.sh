#!/usr/bin/env bash

file="${1/#\~/$HOME}"

if [[ $(file -b "$file") == directory ]]; then
    # tree -C "$file"
    if command -v eza &> /dev/null; then
        eza -la --color=always --icons -g --group-directories-first "$file"
    else
        gls -hFNla --color=always --group-directories-first --hyperlink=auto "$file"
    fi
    exit
fi

mime=$(file --dereference --brief --mime-type "$file")

if [[ $mime =~ \-binary ]]; then
    file "$file"
    exit
fi

image_previewer() {
    # kitty's icat works only in normal tmux pane but fails in tmux popup (see:
    # https://github.com/junegunn/fzf/issues/3972 and https://github.com/tmux/tmux/issues/4329)
    if [[ ! $TERM =~ "tmux" && -z $NVIM ]]; then
        if [[ $KITTY_WINDOW_ID || $GHOSTTY_BIN_DIR ]]; then
            kitty icat --clear --transfer-mode=memory --unicode-placeholder --stdin=no --align left --place="${FZF_PREVIEW_COLUMNS}x$((FZF_PREVIEW_LINES - 1))"@0x0 "$1" | sed '$d' | sed $'$s/$/\e[m/'
            # NOTE:
            # --transfer-mode=memory is the fastest option but if we want fzf to be able to redraw
            # the image on terminal resize or on 'change-preview-window', we need to use
            # --transfer-mode=stream.
        elif [[ $WEZTERM_PANE || $ALACRITTY_WINDOW_ID ]]; then
            chafa -s "${FZF_PREVIEW_COLUMNS}x$((FZF_PREVIEW_LINES - 1))" --animate off --polite on "$1"
        else
            printf "Image preview is not supported"
        fi
    else
        printf "Image preview is not supported"
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
