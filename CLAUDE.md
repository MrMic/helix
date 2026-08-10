# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal Helix editor configuration, not an application. There is nothing to build
or test; "correct" means Helix loads the config and the configured language servers
actually spawn. The editor binary is `hx-steel` (`~/.local/bin/hx-steel`), a
Steel-enabled Helix built from `~/src/helix` — **not** the `hx` on PATH, which is a
plain Homebrew build with no Steel support. Use `hx-steel` for every check.

`~/src/helix` is also the authority for defaults: its `languages.toml` holds the
stock language definitions and `helix-view/src/editor.rs` the stock editor settings.
Read those before adding anything here.

## Verifying a change

```bash
python3 -c "import tomllib; tomllib.load(open('languages.toml','rb'))"   # syntax
hx-steel --health <language>       # per-language servers, formatter, queries
hx-steel --health | head           # config/log paths, runtime dirs
```

`--health` only resolves the `command` binary. It does not validate `args`,
classpaths, jars or probe directories — those need running the server directly.
Node-based servers live under nvm, so run health checks through an interactive
shell (`zsh -ic '...'`) or they will report false negatives.

Runtime behaviour lands in `~/.cache/helix/helix.log`. Default level is WARN;
`hx-steel -v` adds INFO with full LSP message bodies (single lines can exceed 80k
chars — don't open that log in the editor).

To check something that needs a real editor session, drive one in a scratch dir
rather than the user's panes:

```bash
timeout 8 script -qec "hx-steel file.ext" /dev/null </dev/null >/dev/null 2>&1
```

To check whether a language server answers for a given `languageId`, speak LSP to
it over stdio directly (initialize → didOpen → completion). This is the only way to
know before wiring it in; several servers return nothing for languages they do not
recognise.

## Config semantics that cause silent breakage

**User lists replace Helix defaults, they never merge.** Writing `file-types`,
`language-servers` or `roots` in a `[[language]]` block discards everything the
stock definition had. This has already cost `.mjs`/`.cjs`/`.jsx` detection and the
`.prettierrc`/`.clang-format` yaml globs. Diff against `~/src/helix/languages.toml`
and re-list what should stay. Same for `[editor.auto-pairs]` in `config.toml`.

**`file-types` strings are extensions**, or a whole filename only when the file has
no extension. `"application-*.yml"` matches nothing; globs need `{ glob = "..." }`.

**Settings equal to Helix defaults are deleted on sight** here — `config.toml` is
deliberately minimal. Check `editor.rs` before adding a line.

## Language server layout

`~/.local/share/helix-lsp/` holds jdtls, lemminx and spring-boot-ls as **copies**,
plus symlinks for the node-version-dependent angular probe paths. Never point this
config at `~/.local/share/{LazyVim,nvChad}/mason/...`: those directories get wiped
whenever an nvim distro is reinstalled, which has broken java and xml twice.

`required-root-patterns` gates a server on a marker file in the project root
(top-level only, no recursion). It is how `intelephense` (`artisan`) and `phpactor`
(`symfony.lock`) are kept to their own frameworks, and how `laravel-ls` stays out of
non-Laravel projects.

Before installing any language server, check whether one is already on disk: Doom
Emacs and mason share this machine and often have it already.

## Steel and herdr

`helix.scm` defines commands exposed as `:hello-steel` and `:open-helix-scm`;
`init.scm` is empty but must exist for the Steel runtime.

`herdr-split.sh` and `yazi-picker.sh` back the `C-y` and `backspace a` bindings.
herdr exports `HERDR_PANE_ID`, `HERDR_SOCKET_PATH` and `HERDR_TAB_ID` into every
pane and Helix passes its environment to `:sh` children, so scripts must read
`HERDR_PANE_ID` to find the editor's pane — resolving it from `herdr pane list`'s
`focused` flag is wrong, since focus moves. `herdr pane split` does not focus the
new pane unless given `--focus`.

## Themes

`themes/<name>+.toml` files `inherit` a stock theme and override
`ui.virtual.inlay-hint` with **literal hex**, deliberately not palette names, so
hints look identical across themes. Add a theme by copying one of these and
changing `inherits`.

## Other agents on this machine

An OpenAI Codex config (`~/.codex/config.toml`) and a Gemini CLI config
(`~/.gemini/settings.json`) exist. To pull their user-level items (MCP servers,
slash commands, subagents, skills, instructions) into Claude Code, reply `/import`
to list what is importable, then `/import --yes=<digest>` to apply it.
