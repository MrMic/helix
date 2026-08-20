#!/usr/bin/env bash
# Wrap piped selection in <tag>...</tag>. Prompts for the tag via rofi (reads
# /dev/null so :pipe's stdin stays intact), then perl reads the selection
# straight off stdin -- keeps every byte, including the trailing newline.
# Tag can also be passed as $1 to skip the rofi prompt.
# Colors live in rofi-tag.rasi (full theme, replaces rofi's default so nothing
# overrides the text color). Edit the hex values there.
tag=${1:-$(rofi -dmenu -p tag -theme ~/.config/helix/rofi-tag.rasi </dev/null)}
tag=${tag:-div}
# Keep leading whitespace before <tag> and trailing whitespace after </tag> so
# indentation and the trailing newline survive untouched.
exec perl -0777 -pe "s{\\A(\\s*)(.*?)(\\s*)\\z}{\$1<$tag>\$2</$tag>\$3}s"
