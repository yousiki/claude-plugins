# php-lsp

[`intelephense`](https://intelephense.com/) packaged for Claude Code with a no-global-install launcher.

## What it is

`intelephense` is a PHP language server providing diagnostics, completion, hover, go-to-definition, and other IDE features for `.php` files.

## How it runs

JS/TS chain, in order:

1. `bunx intelephense`
2. `pnpm dlx intelephense`
3. `npx -y intelephense`

At least one of bun / pnpm / node must be on `PATH`. `intelephense` is published on npm under the same package name as its binary, so no `-p`/`--package` mapping is needed.

Claude Code starts the server with `--stdio`; the marketplace entry supplies that through `args`.

## Extensions

This plugin registers:

- `.php`

## Notes

- Intelephense is "Freemium" software: the core language server is free, with a paid license unlocking additional features (e.g. full rename-across-files, PHPDoc-based type inference). This plugin runs the free tier as-is.
- If none of bunx, pnpm, or npx are available, the launcher exits 127 and prints install URLs for the supported runtimes.
