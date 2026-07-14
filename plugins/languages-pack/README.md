# languages-pack

One-install bundle combining every non-overlapping language server and formatter hook in this marketplace, for users who want broad multi-language coverage without picking through individual plugins.

## What it is

`languages-pack` re-registers the `lspServers` and `hooks` blocks of several standalone plugins in this repo under a single plugin. It doesn't vendor any new tools — each zero-install entry uses the same runtime-fallback launcher pattern as its standalone counterpart, copied into this plugin's `scripts/` folder; each native-toolchain entry invokes the same direct binary command as its standalone counterpart.

## Language servers — zero-install (runtime fallback chain)

These resolve their tool on demand through `bunx`/`pnpm dlx`/`npx` or `uvx`/`pipx run` — nothing to install beyond the runtime itself.

| Server | Languages | Standalone equivalent |
| --- | --- | --- |
| `biome` | JS, JSX, TS, TSX, JSON, JSONC, CSS, GraphQL | [`biome-lsp`](../biome-lsp) |
| `vscode-html` | HTML | [`vscode-html-lsp`](../vscode-html-lsp) |
| `bash` | Bash, shell | [`bash-lsp`](../bash-lsp) |
| `basedpyright` | Python | [`basedpyright-lsp`](../basedpyright-lsp) |
| `tombi` | TOML | [`tombi-lsp`](../tombi-lsp) |
| `yaml` | YAML | [`yaml-lsp`](../yaml-lsp) |
| `intelephense` | PHP | [`php-lsp`](../php-lsp) |
| `liquid` | Shopify Liquid | [`liquid-lsp`](../liquid-lsp) |

`biome-lsp` was chosen over `typescript-lsp` / `vscode-json-lsp` / `vscode-css-lsp` for JS/TS/JSON/CSS coverage, since those overlap with Biome on the same extensions. This keeps every extension owned by exactly one language server in this pack — no duplicate or racing diagnostics.

## Language servers — native toolchain (direct command, no fallback)

These servers have no npm/PyPI distribution, so there's no `bunx`/`uvx` chain to wrap — the `lspServers` command is the bare binary name, and **each binary must already be installed and on `$PATH`** (see the standalone plugin's README for install instructions per language). If a binary is missing, Claude Code reports "Executable not found in $PATH" in the `/plugin` Errors panel for that server only; the rest of the pack keeps working.

| Server | Command | Languages | Standalone equivalent |
| --- | --- | --- | --- |
| `clangd` | `clangd` | C, C++ | [`clangd-lsp`](../clangd-lsp) |
| `csharp-ls` | `csharp-ls` | C# | [`csharp-lsp`](../csharp-lsp) |
| `gopls` | `gopls` | Go | [`gopls-lsp`](../gopls-lsp) |
| `jdtls` | `jdtls` | Java | [`jdtls-lsp`](../jdtls-lsp) |
| `kotlin-lsp` | `kotlin-lsp --stdio` | Kotlin | [`kotlin-lsp`](../kotlin-lsp) |
| `lua` | `lua-language-server` | Lua | [`lua-lsp`](../lua-lsp) |
| `ruby-lsp` | `ruby-lsp` | Ruby, ERB | [`ruby-lsp`](../ruby-lsp) |
| `rust-analyzer` | `rust-analyzer` | Rust | [`rust-analyzer-lsp`](../rust-analyzer-lsp) |
| `sourcekit-lsp` | `sourcekit-lsp` | Swift | [`swift-lsp`](../swift-lsp) |

## Formatter hooks

All three formatter hooks in the marketplace are included together since they already cover disjoint extensions:

| Hook | Files formatted |
| --- | --- |
| `ruff-format-hook.sh` | `.py`, `.pyi` |
| `biome-format-hook.sh` | `.js`, `.mjs`, `.cjs`, `.jsx`, `.ts`, `.mts`, `.cts`, `.tsx`, `.json`, `.jsonc` |
| `prettier-format-hook.sh` | `.css`, `.scss`, `.less`, `.html`, `.htm`, `.md`, `.markdown`, `.mdx`, `.yaml`, `.yml` |

Each hook runs on `PostToolUse` for `Write | Edit | MultiEdit`, inspects the written file's extension, and exits silently if it's out of scope for that hook.

## Runtime requirements

- JS/TS chain (`bunx` / `pnpm dlx` / `npx`) for `biome`, `vscode-html`, `bash`, `yaml`, `intelephense`, `liquid`, and the Biome/Prettier formatter hooks.
- Python chain (`uvx` / `pipx run`) for `basedpyright`, `tombi`, and the ruff formatter hook.
- Per-language native toolchain (LLVM, .NET SDK, Go, JDK, JetBrains kotlin-lsp, Lua, Ruby, Rust, Swift) for `clangd`, `csharp-ls`, `gopls`, `jdtls`, `kotlin-lsp`, `lua`, `ruby-lsp`, `rust-analyzer`, and `sourcekit-lsp` — these don't have a JS/TS or Python fallback chain at all, so the tool must already be installed and on `PATH`.

Missing a chain, or a missing native-toolchain binary, only disables the server(s) that depend on it; the rest keep working.

## Coexistence

Don't install `languages-pack` alongside its standalone equivalents (`biome-lsp`, `typescript-lsp`, `vscode-json-lsp`, `vscode-css-lsp`, `vscode-html-lsp`, `bash-lsp`, `basedpyright-lsp`, `tombi-lsp`, `yaml-lsp`, `php-lsp`, `liquid-lsp`, `clangd-lsp`, `csharp-lsp`, `gopls-lsp`, `jdtls-lsp`, `kotlin-lsp`, `lua-lsp`, `ruby-lsp`, `rust-analyzer-lsp`, `swift-lsp`, `biome-formatter`, `prettier-formatter`, `ruff-formatter`) — that would register the same extension twice and cause conflicting or racing diagnostics/formatting. Pick either the individual plugins or this pack, not both.

## Files

- `.claude-plugin/plugin.json` - combined `lspServers` and `hooks` metadata.
- `scripts/launch-*.sh` - runtime-fallback wrappers, one per zero-install language server (identical to the standalone plugin's script). The native-toolchain servers (`clangd`, `csharp-ls`, `gopls`, `jdtls`, `kotlin-lsp`, `lua`, `ruby-lsp`, `rust-analyzer`, `sourcekit-lsp`) have no wrapper script — their `plugin.json` command is the bare binary name, same as their standalone plugin.
- `scripts/*-format-hook.sh` - the three formatter hook scripts (identical to the standalone plugins' scripts).
