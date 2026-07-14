# lua-lsp

[`lua-language-server`](https://github.com/LuaLS/lua-language-server) Lua language server for Claude Code.

## What it is

`lua-language-server` provides diagnostics, completion, hover, and go-to-definition for Lua code, including type-annotation-aware checking via its own annotation syntax.

## No runtime fallback chain

`lua-language-server` ships as compiled platform binaries via GitHub releases (or your OS package manager), not an npm or PyPI package — there's no `bunx`/`uvx` chain to fall back through. This plugin's `lspServers` entry invokes `lua-language-server` directly, so **the binary must already be on `$PATH`.**

Install it with one of:

- macOS: `brew install lua-language-server`
- Arch: `pacman -S lua-language-server`
- Manual: download a release from [LuaLS/lua-language-server releases](https://github.com/LuaLS/lua-language-server/releases) and put the bundled `lua-language-server` script/binary on `PATH`

## Extensions

This plugin registers:

- `.lua` → Lua

## Notes

- If `lua-language-server` isn't found on `$PATH`, Claude Code will report "Executable not found in $PATH" in the `/plugin` Errors panel — install it with one of the methods above and reload.
