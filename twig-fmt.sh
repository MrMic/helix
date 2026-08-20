#!/usr/bin/env bash
# Format twig on stdin with prettier + @zackad/prettier-plugin-twig.
# Resolves the global plugin from prettier's own install dir so a node version
# bump doesn't break the path (no hardcoded nvm version).
# ponytail: `npm root -g` resolves the global modules dir at runtime; if the
# plugin is missing, reinstall with `npm i -g @zackad/prettier-plugin-twig`.
plugin="$(npm root -g)/@zackad/prettier-plugin-twig/src/index.js"
# --twig-always-break-objects=false keeps { id: x } inline instead of exploding
# every object; --print-width gives lines room before wrapping.
exec prettier --stdin-filepath x.html.twig --plugin="$plugin" \
    --twig-always-break-objects=false --print-width=120
