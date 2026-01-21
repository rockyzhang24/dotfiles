#!/usr/bin/env bash

# Popup helper for tmux.
#
# This script opens a command inside a tmux popup while keeping its state across openings. It does
# so by mapping the given command to a stable, hidden tmux session (identified by a hash of the
# command), and attaching that session inside a popup.
#
# Closing the popup only detaches from the session; the underlying process keeps running and will be
# reused next time the same command is invoked.
#
# Typical use cases include TUI tools such as lazygit, yazi, database CLIs, or chat/AI clients that
# benefit from persistent state without polluting the main tmux window layout.
#
# Usage: popup.sh <command>

cmd="$*"

# Generate the session name
hash=$(printf "%s" "$cmd" | md5 | cut -c1-8)
session="popup-$hash"

# Run <command> under the cwd of the current pane
cwd="$(tmux display-message -p '#{pane_current_path}')"

tmux new-session -d -s "$session" -c "$cwd" "$cmd" 2>/dev/null

tmux display-popup -E \
    -w 80% -h 80% \
    -T "$cmd" \
    -e "COMMAND_POPUP=1" \
    "tmux set -q status off \; attach -t $session"
