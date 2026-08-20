#!/usr/bin/env bash
# Launches helix-gpt with the GitHub Copilot handler, reading the OAuth token
# from the standard Copilot creds file so it never lands in git-tracked config.
# Backs the `gpt` language-server in languages.toml.
set -euo pipefail

apps="${HOME}/.config/github-copilot/apps.json"

token="$(python3 - "$apps" <<'PY'
import json, sys
for v in json.load(open(sys.argv[1])).values():
    if isinstance(v, dict) and v.get("oauth_token"):
        print(v["oauth_token"]); break
PY
)"

if [ -z "$token" ]; then
    echo "helix-gpt.sh: no Copilot oauth_token in $apps" >&2
    exit 1
fi

exec helix-gpt --handler copilot --copilotApiKey "$token" "$@"
