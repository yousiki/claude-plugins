# languages-pack

One-install bundle combining every non-overlapping language server and formatter hook in this marketplace, for users who want broad multi-language coverage without picking through individual plugins.

## What it is

`languages-pack` re-registers the `lspServers` and `hooks` blocks of several standalone plugins in this repo under a single plugin. It doesn't vendor any new tools — each entry uses the same runtime-fallback launcher pattern as its standalone counterpart, copied into this plugin's `scripts/` folder.

## Language servers

| Server | Languages | Standalone equivalent |
| --- | --- | --- |
| `biome` | JS, JSX, TS, TSX, JSON, JSONC, CSS, GraphQL | [`biome-lsp`](../biome-lsp) |
| `vscode-html` | HTML | [`vscode-html-lsp`](../vscode-html-lsp) |
| `bash` | Bash, shell | [`bash-lsp`](../bash-lsp) |
| `basedpyright` | Python | [`basedpyright-lsp`](../basedpyright-lsp) |
| `tombi` | TOML | [`tombi-lsp`](../tombi-lsp) |
| `yaml` | YAML | [`yaml-lsp`](../yaml-lsp) |

`biome-lsp` was chosen over `typescript-lsp` / `vscode-json-lsp` / `vscode-css-lsp` for JS/TS/JSON/CSS coverage, since those overlap with Biome on the same extensions. This keeps every extension owned by exactly one language server in this pack — no duplicate or racing diagnostics.

## Formatter hooks

All three formatter hooks in the marketplace are included together since they already cover disjoint extensions:

| Hook | Files formatted |
| --- | --- |
| `ruff-format-hook.sh` | `.py`, `.pyi` |
| `biome-format-hook.sh` | `.js`, `.mjs`, `.cjs`, `.jsx`, `.ts`, `.mts`, `.cts`, `.tsx`, `.json`, `.jsonc` |
| `prettier-format-hook.sh` | `.css`, `.scss`, `.less`, `.html`, `.htm`, `.md`, `.markdown`, `.mdx`, `.yaml`, `.yml` |

Each hook runs on `PostToolUse` for `Write | Edit | MultiEdit`, inspects the written file's extension, and exits silently if it's out of scope for that hook.

## Runtime requirements

- JS/TS chain (`bunx` / `pnpm dlx` / `npx`) for `biome`, `vscode-html`, `bash`, `yaml`, and the Biome/Prettier formatter hooks.
- Python chain (`uvx` / `pipx run`) for `basedpyright`, `tombi`, and the ruff formatter hook.

Missing a chain entirely disables the servers/hooks that depend on it; the rest keep working.

## Coexistence

Don't install `languages-pack` alongside its standalone equivalents (`biome-lsp`, `typescript-lsp`, `vscode-json-lsp`, `vscode-css-lsp`, `vscode-html-lsp`, `bash-lsp`, `basedpyright-lsp`, `tombi-lsp`, `yaml-lsp`, `biome-formatter`, `prettier-formatter`, `ruff-formatter`) — that would register the same extension twice and cause conflicting or racing diagnostics/formatting. Pick either the individual plugins or this pack, not both.

## Files

- `.claude-plugin/plugin.json` - combined `lspServers` and `hooks` metadata.
- `scripts/launch-*.sh` - runtime-fallback wrappers, one per language server (identical to the standalone plugin's script).
- `scripts/*-format-hook.sh` - the three formatter hook scripts (identical to the standalone plugins' scripts).
