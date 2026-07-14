# liquid-lsp

[Shopify's theme language server](https://shopify.dev/docs/storefronts/themes/tools/cli/language-server) packaged for Claude Code with a no-global-install launcher.

## What it is

Shopify ships Liquid/theme language support as a subcommand of its CLI (`shopify theme language-server`), backed by `@shopify/theme-language-server-node` under the hood. It provides diagnostics, completion, and hover for Liquid template objects, tags, and filters in `.liquid` files.

## How it runs

JS/TS chain, in order:

1. `bunx -p @shopify/cli shopify theme language-server`
2. `pnpm --package=@shopify/cli dlx shopify -- theme language-server`
3. `npx -y --package=@shopify/cli shopify -- theme language-server`

At least one of bun / pnpm / node must be on `PATH`. The npm package is `@shopify/cli`; its binary is `shopify`, and the language server is one of its subcommands rather than a standalone executable, so the launcher maps package to binary explicitly (same `-p`/`--package` pattern as `vscode-html-lsp`).

The subcommand communicates over stdio by default — no extra `--stdio` flag is needed.

## Extensions

This plugin registers:

- `.liquid`

## Notes

- `@shopify/cli` is a larger package than a single-purpose language-server package (it's the full Shopify CLI), since Shopify does not currently publish a standalone CLI binary for just the language server. `bunx`/`npx`/`pnpm dlx` still resolve and cache it like any other on-demand package.
- If none of bunx, pnpm, or npx are available, the launcher exits 127 and prints install URLs for the supported runtimes.
