# kotlin-lsp

[JetBrains' `kotlin-lsp`](https://github.com/Kotlin/kotlin-lsp) Kotlin language server for Claude Code.

## What it is

`kotlin-lsp` is JetBrains' official Language Server Protocol implementation for Kotlin, built on the same Kotlin Analysis API used by IntelliJ IDEA. It's currently pre-alpha upstream.

## No runtime fallback chain

`kotlin-lsp` is distributed via Homebrew or GitHub release archives, not an npm or PyPI package — there's no `bunx`/`uvx` chain to fall back through. This plugin's `lspServers` entry invokes `kotlin-lsp` directly, so **the binary must already be on `$PATH`.**

Install it with one of:

- macOS/Linux: `brew install JetBrains/utils/kotlin-lsp`
- Manual: download a release from [Kotlin/kotlin-lsp releases](https://github.com/Kotlin/kotlin-lsp/releases) and put the `kotlin-lsp.sh` (or the newer native `bin/intellij-server` launcher) on `PATH` as `kotlin-lsp`

## Extensions

This plugin registers:

- `.kt`, `.kts` → Kotlin

## Notes

- If `kotlin-lsp` isn't found on `$PATH`, Claude Code will report "Executable not found in $PATH" in the `/plugin` Errors panel — install it with one of the methods above and reload.
- `startupTimeout` is set to 120s: like JDT.LS, `kotlin-lsp` indexes the project on first launch.
- Upstream is pre-alpha; expect rougher edges than the more mature servers in this marketplace.
