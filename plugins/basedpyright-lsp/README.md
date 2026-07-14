# basedpyright-lsp

[Basedpyright](https://github.com/DetachHead/basedpyright) language server, packaged for Claude Code.

Basedpyright is a community fork of Microsoft's Pyright with stricter defaults and extra diagnostics enabled out of the box:

- stricter type narrowing / catch more bugs out of the box
- `reportUnreachable`, `reportImplicitStringConcatenation`, and similar opt-in-in-pyright rules enabled by default
- features that haven't yet been upstreamed into Microsoft pyright

## Runtime

Python chain, in order:

1. `uvx --from basedpyright basedpyright-langserver` — preferred
2. `pipx run --spec basedpyright basedpyright-langserver`

Why `--from` / `--spec`: the PyPI package is `basedpyright` but the language server bin is `basedpyright-langserver`. Without the flag, uvx/pipx would look for a package named `basedpyright-langserver` and fail.

## Notes

- No `python3 -m` fallback: basedpyright doesn't expose a reliable module entry point.
- Claude Code passes `--stdio` via the marketplace entry's `args` field.
