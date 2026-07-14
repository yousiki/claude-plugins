# rust-analyzer-lsp

[`rust-analyzer`](https://rust-analyzer.github.io/) Rust language server for Claude Code.

## What it is

`rust-analyzer` is the official Rust language server: diagnostics, completion, inlay hints, go-to-definition, and refactoring for Cargo-based Rust projects.

## No runtime fallback chain

`rust-analyzer` is a native binary distributed via `rustup` or GitHub releases, not an npm or PyPI package — there's no `bunx`/`uvx` chain to fall back through. This plugin's `lspServers` entry invokes `rust-analyzer` directly, so **the binary must already be on `$PATH`.**

Install it with one of:

- `rustup component add rust-analyzer` (recommended if you already manage Rust via `rustup`)
- Manual: download a release from [rust-lang/rust-analyzer releases](https://github.com/rust-lang/rust-analyzer/releases), rename it to `rust-analyzer`, make it executable, and put it on `PATH`

## Extensions

This plugin registers:

- `.rs` → Rust

## Notes

- If `rust-analyzer` isn't found on `$PATH`, Claude Code will report "Executable not found in $PATH" in the `/plugin` Errors panel — install it with one of the methods above and reload.
- Works best inside a directory with a `Cargo.toml` so it can resolve crate dependencies.
