# prettier-formatter

A PostToolUse hook that runs Prettier on CSS, SCSS, Less, HTML, Markdown, MDX, and YAML files Claude touches via `Write`, `Edit`, or `MultiEdit`.

## Coverage

JS, TS, and JSON are formatted by [`biome-formatter`](../biome-formatter) instead. This plugin covers the extensions Biome doesn't format: CSS/SCSS/Less, HTML, Markdown/MDX, and YAML. Together the two plugins format every extension below with no overlap.

## Runtime

JavaScript chain, in order:

1. `bunx prettier --write -- <file>` - preferred
2. `pnpm dlx prettier -- --write -- <file>` - fallback
3. `npx -y prettier --write -- <file>` - fallback

Install one:

- https://bun.sh
- https://pnpm.io
- https://nodejs.org

If none is present, the hook logs a one-line skip warning and exits cleanly.

## What it does

- After any `Write | Edit | MultiEdit`, the hook inspects the tool input.
- If the written file ends in `.css`, `.scss`, `.less`, `.html`, `.htm`, `.md`, `.markdown`, `.mdx`, `.yaml`, or `.yml`, it runs `prettier --write -- <file>` in place.
- Any other extension exits silently (including `.js`/`.ts`/`.json`, which `biome-formatter` owns).
- Prettier discovers project configuration and ignore files through its normal rules.

## Coexistence

- Install alongside `biome-formatter` for full-coverage formatting with no overlap.
- Do not install another formatter hook that also claims `.css`, `.html`, `.md`, or `.yaml` — two hooks can race on the same file since `PostToolUse` hooks may run in parallel.

## Files

- `.claude-plugin/plugin.json` - plugin metadata.
- `scripts/prettier-format-hook.sh` - POSIX sh hook script that parses stdin JSON and formats matching files.
- `README.md` - usage notes and coexistence rules.

Runtime configuration (the `hooks` block) belongs in the root `.claude-plugin/marketplace.json` entry.

## Smoke testing

Feed a hook event containing a matching `tool_input.file_path` into `scripts/prettier-format-hook.sh`.
The file should be rewritten by Prettier when one runtime is installed.
Out-of-scope files (including `.js`/`.ts`/`.json`) should produce no output and exit 0.
