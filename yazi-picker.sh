#!/usr/bin/env bash
# Pick files with yazi in a herdr pane and open them back in helix.
# Spawned by herdr-split.sh, which exports HX_PANE (the editor's pane).
# HERDR_PANE_ID is set by herdr itself and identifies this pane.
#
#   usage: yazi-picker.sh [open|vsplit|hsplit]
set -euo pipefail

mode=${1:-open}
hx_pane=${HX_PANE:?no editor pane given}

case $mode in
vsplit) command=":vsplit" ;;
hsplit) command=":hsplit" ;;
*) command=":open" ;;
esac

chooser=$(mktemp)
trap 'rm -f "$chooser"' EXIT

# A real file, not /dev/stdout: yazi draws its interface on this terminal, so
# capturing stdout would mix escape sequences into the paths.
yazi --chooser-file="$chooser"

# yazi writes the last path without a trailing newline, so the `|| [[ -n ]]`
# is required: a plain `while read` drops that final line entirely.
paths=$(while IFS= read -r line || [[ -n $line ]]; do printf "%q " "$line"; done <"$chooser")

if [[ -n $paths ]]; then
	# Leave whatever mode helix is in before typing a command.
	herdr pane send-keys "$hx_pane" Escape
	herdr pane send-text "$hx_pane" "$command $paths"
	herdr pane send-keys "$hx_pane" Enter
fi

herdr pane close "$HERDR_PANE_ID"
