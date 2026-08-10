#!/usr/bin/env bash
# Split the pane helix runs in and start a command in the new pane.
#
#   usage: herdr-split.sh <right|down> <command...>
#
# herdr exports HERDR_PANE_ID into every pane, and helix passes its environment
# on to :sh children, so the editor's pane is known exactly. Do not resolve it
# by looking for the focused pane: focus may have moved elsewhere by then.
#
# The spawned command receives HX_PANE so it can send text back to the editor.
set -euo pipefail

direction=$1
shift

hx_pane=${HERDR_PANE_ID:?not running inside a herdr pane}

# --focus keeps you in the new pane (splitting does not focus by default), and
# --env passes the editor's pane id without smuggling it through the command line.
new_pane=$(herdr pane split "$hx_pane" \
	--direction "$direction" \
	--focus \
	--env "HX_PANE=$hx_pane" | python3 -c \
	'import sys, json; print(json.load(sys.stdin)["result"]["pane"]["pane_id"])')

herdr pane run "$new_pane" "$*"
