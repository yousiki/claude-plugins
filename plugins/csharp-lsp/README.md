# csharp-lsp

[`csharp-ls`](https://github.com/razzmatazz/csharp-language-server) C# language server for Claude Code.

## What it is

`csharp-ls` provides diagnostics, completion, hover, go-to-definition, and find-references for C# projects, built on the Roslyn compiler platform.

## No runtime fallback chain

`csharp-ls` is distributed as a .NET global tool, not an npm or PyPI package — there's no `bunx`/`uvx` chain to fall back through. This plugin's `lspServers` entry invokes `csharp-ls` directly, so **the tool must already be on `$PATH`.**

Install it with the .NET SDK on `PATH`:

```sh
dotnet tool install --global csharp-ls
```

This adds `csharp-ls` under `~/.dotnet/tools`, which the .NET SDK installer normally adds to `PATH` automatically.

## Extensions

This plugin registers:

- `.cs` → C#

## Notes

- If `csharp-ls` isn't found on `$PATH`, Claude Code will report "Executable not found in $PATH" in the `/plugin` Errors panel — install it with the command above and reload.
- `csharp-ls` works best when a `.sln` or `.csproj` is present so it can resolve project references.
