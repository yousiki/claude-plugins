# context7

Upstash [Context7](https://github.com/upstash/context7) MCP server for up-to-date documentation lookup. Pulls version-specific docs and code examples into the session.

Exposes two tools:

- `resolve-library-id` — resolve a free-form library name to a Context7-compatible library ID.
- `query-docs` — fetch focused, version-specific documentation for a resolved library ID.

## Runtime

None. Context7 is a remote streamable-HTTP MCP endpoint at `https://mcp.context7.com/mcp`. No local process, no npm/pip, no launcher.

## Auth

Anonymous access works out of the box but is rate-limited to ~1000 calls/month per the upstream README. If you want higher limits, grab a key from [context7.com/dashboard](https://context7.com/dashboard) and attach it as a `CONTEXT7_API_KEY` header on the MCP server entry — edit `~/.claude.json` (or whichever scoped MCP config you use) and add:

```json
"headers": { "CONTEXT7_API_KEY": "<your-key>" }
```

alongside the `url` in the `context7` server entry. This plugin ships the anonymous configuration; the per-user override is not bundled here.

## Files

- `.claude-plugin/plugin.json` — plugin metadata.
- `.mcp.json` — MCP server declaration (remote streamable HTTP, `https://mcp.context7.com/mcp`).
