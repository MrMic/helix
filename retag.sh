#!/usr/bin/env bash
# Rename the outermost HTML tag of the selection (nvim-surround's `cst`).
# Keeps the opening tag's attributes; only the tag name changes. Prompts for
# the new name via rofi (same theme as htag.sh). Empty input = leave unchanged.
new=${1:-$(rofi -dmenu -p 'new tag' -theme ~/.config/helix/rofi-tag.rasi 2>/dev/null </dev/null)}
[ -z "$new" ] && exec cat
# $2 in the regex captures the attributes after the tag name on the open tag.
exec perl -0777 -pe "s{\\A(\\s*)<[^ />]+([^>]*)>(.*)</[^>]+>(\\s*)\\z}{\$1<$new\$2>\$3</$new>\$4}s"
