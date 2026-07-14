# gopls-lsp

[`gopls`](https://pkg.go.dev/golang.org/x/tools/gopls) Go language server for Claude Code.

## What it is

`gopls` (pronounced "go please") is the official Go language server: diagnostics, completion, refactoring, go-to-definition, and more, built on the same analysis engine as the `go` toolchain.

## No runtime fallback chain

`gopls` is a Go module tool, not an npm or PyPI package — there's no `bunx`/`uvx` chain to fall back through. This plugin's `lspServers` entry invokes `gopls` directly, so **the binary must already be on `$PATH`.**

Install it with the Go toolchain on `PATH`:

```sh
go install golang.org/x/tools/gopls@latest
```

This installs `gopls` to `$(go env GOPATH)/bin` (often `~/go/bin`) — make sure that directory is on `PATH`.

## Extensions

This plugin registers:

- `.go` → Go

## Notes

- If `gopls` isn't found on `$PATH`, Claude Code will report "Executable not found in $PATH" in the `/plugin` Errors panel — install it with the command above (and check `$(go env GOPATH)/bin` is on `PATH`) then reload.
- `gopls` works best inside a directory with a `go.mod` so it can resolve module dependencies.
