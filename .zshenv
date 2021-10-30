#!/bin/zsh

# Environment variables
source $HOME/.config/zsh/env

# Change zsh dotfiles location
export ZDOTDIR="$HOME/.config/zsh"

# Define Zim location
export ZIM_HOME="${ZDOTDIR:-${HOME}}/.zim"
