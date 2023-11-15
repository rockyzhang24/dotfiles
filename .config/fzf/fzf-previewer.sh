#!/usr/bin/env bash

if [[ $(file -b "$1") == directory ]]; then
  tree -C "$1"
  exit
fi

mime=$(file --dereference --brief --mime "$1")

if [[ $mime =~ =binary ]]; then
  file "$1"
  exit
fi

(bat --color=always --style=numbers,changes,header "$1" \
  || highlight --out-format truecolor --style darkplus --force --line-numbers "$1" \
  || cat "$1") | head -200 \
  || echo -e " No preview supported for the current selection:\n\n $1"
