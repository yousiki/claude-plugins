# swift-lsp

[SourceKit-LSP](https://github.com/swiftlang/sourcekit-lsp) Swift language server for Claude Code.

## What it is

SourceKit-LSP provides diagnostics, completion, hover, and go-to-definition for Swift (and Swift/C/C++ interop) code, built on the same SourceKit infrastructure Xcode uses.

## No runtime fallback chain

`sourcekit-lsp` is a native binary bundled with a Swift toolchain, not an npm or PyPI package — there's no `bunx`/`uvx` chain to fall back through. This plugin's `lspServers` entry invokes `sourcekit-lsp` directly, so **the binary must already be on `$PATH`.**

It's typically already available once a Swift toolchain is installed:

- macOS: install Xcode or the Xcode Command Line Tools (`xcode-select --install`) — `sourcekit-lsp` ships inside the toolchain and is usually resolvable via `xcrun sourcekit-lsp`; symlink or wrap it onto `PATH` as `sourcekit-lsp` if `xcrun` indirection is needed
- Linux: install a Swift toolchain from [swift.org](https://www.swift.org/install/) — `sourcekit-lsp` is included under the toolchain's `usr/bin`, which the installer typically adds to `PATH`

## Extensions

This plugin registers:

- `.swift` → Swift

## Notes

- If `sourcekit-lsp` isn't found on `$PATH`, Claude Code will report "Executable not found in $PATH" in the `/plugin` Errors panel — install a Swift toolchain as above and reload.
- Works best inside a Swift Package Manager project (a `Package.swift` at the root) so it can resolve module dependencies.
