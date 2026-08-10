# zotero

[zotero-mcp](https://github.com/54yyyu/zotero-mcp) MCP server for reading, searching, and editing a Zotero library from the session.

The default toolset is 37 tools (verified against v0.9.1), grouped by family:

- **Search** — `zotero_search_items`, `zotero_advanced_search`, `zotero_search_by_tag`, `zotero_search_by_citation_key`, `zotero_search_collections`, `zotero_get_collections`, `zotero_get_collection_items`, `zotero_get_tags`, `zotero_get_recent`.
- **Content** — `zotero_get_item_metadata` (markdown / JSON / BibTeX), `zotero_get_item_fulltext`, `zotero_get_item_children`, `zotero_get_pdf_outline`, `zotero_read_pdf_pages`, `zotero_get_page_layout`, `zotero_get_attachment_path`, `zotero_export_bibliography`.
- **Annotations & notes** — `zotero_get_annotations`, `zotero_create_annotation`, `zotero_update_annotation`, `zotero_delete_annotation`, `zotero_synthesize_annotations`, `zotero_get_notes`, `zotero_manage_note`.
- **Item & collection management** — `zotero_add_item`, `zotero_update_item`, `zotero_batch_update`, `zotero_delete_item`, `zotero_attach_file`, `zotero_create_collection`, `zotero_delete_collection`, `zotero_set_item_collections`. These need write access, which the local API doesn't have — see [Configuration](#configuration).
- **Libraries** — `zotero_list_libraries`, `zotero_switch_library`.
- **Semantic search** — `zotero_semantic_search`, `zotero_update_search_database`, `zotero_get_search_database_status`. Present by default but they need the `[semantic]` extra to actually run; see [Semantic search](#semantic-search).

Further groups (`scite`, `duplicates`, `discovery`, `feeds`, `relations`) are off by default and gated behind `ZOTERO_MCP_TOOLSETS` — see [Toolsets](#toolsets).

## Setup

```text
/zotero:setup
```

The slash command probes the runtime, warms the package cache, detects whether Zotero's local API is answering, asks whether you want local / web / hybrid access, and writes the config file. Run `/mcp` afterwards to reconnect the server.

Local-only, read-only use needs no setup at all — with no config file the server defaults to `ZOTERO_LOCAL=true`.

## Runtime

Python, resolved on demand: `uvx` → `pipx run`. Nothing is installed globally.

The PyPI distribution is **`zotero-mcp-server`** and the bin is `zotero-mcp`, so the launcher passes an explicit `--from` / `--spec`. (`zotero-mcp` on PyPI is a different, unrelated project — the launcher must never resolve it by that name.)

The launcher pins the interpreter with `uvx --python 3.14`, which resolves to the newest 3.14.x uv knows about; uv downloads a managed build on first run if the host has no 3.14, so there is still nothing to install by hand. Override with `ZOTERO_MCP_PYTHON` (see below). The package itself only requires 3.10+.

The `pipx run` fallback deliberately gets **no** `--python` flag — pipx cannot provision an interpreter, so pinning there would convert a working fallback into a hard failure. It uses whatever Python pipx was installed against.

For local mode you also need Zotero 7+ running with **Settings → Advanced → "Allow other applications on this computer to communicate with Zotero"** enabled. That exposes the read-only local API on `http://localhost:23119`.

## Configuration

Two user-local files, neither of them in this repo:

**`~/.config/zotero-mcp/config.json`** — written by `/zotero:setup`, mode `600`. Its `client_env` map is applied to the server's environment at startup as *defaults*; real environment variables take precedence.

```json
{
  "client_env": {
    "ZOTERO_LOCAL": "true",
    "ZOTERO_NO_CLAUDE": "true"
  }
}
```

| Key | Meaning |
| --- | --- |
| `ZOTERO_LOCAL` | `true` reads from the running Zotero app (read-only). `false` uses api.zotero.org. |
| `ZOTERO_API_KEY` | Web API key, from [zotero.org/settings/security](https://www.zotero.org/settings/security#applications). |
| `ZOTERO_LIBRARY_ID` | Numeric user ID, or group ID for a group library. |
| `ZOTERO_LIBRARY_TYPE` | `user` (default) or `group`. |
| `ZOTERO_NO_CLAUDE` | `true` stops the server from also merging env out of any Claude Desktop config it finds. |
| `ZOTERO_MCP_TOOLSETS` | Which optional tool groups to load — see below. |

Setting `ZOTERO_LOCAL=true` *and* a key/library ID gives hybrid mode: local reads, web-API writes. Worth it if you want the item-management tools, since the local API cannot write.

**`~/.config/zotero-mcp/plugin.env`** — optional, sourced by the launcher. It controls the `uvx` invocation itself, which the server-side config file cannot reach:

| Variable | Effect |
| --- | --- |
| `ZOTERO_MCP_EXTRAS` | Extras appended to the spec, e.g. `"[semantic]"` or `"[all]"`. Default: base install. |
| `ZOTERO_MCP_VERSION` | Version constraint, e.g. `"==0.9.1"`. Default: latest. |
| `ZOTERO_MCP_PYTHON` | Interpreter passed to `uvx --python`. Default: `3.14`. |

This plugin ships no credentials and no `env` block in `.mcp.json`; everything above is per-user.

## Semantic search

The `[semantic]` extra pulls chromadb, sentence-transformers and torch — gigabytes into the uv cache — which is why the launcher installs the base package by default. `/zotero:setup` offers to enable it, or set it by hand:

```sh
printf '%s\n' 'ZOTERO_MCP_EXTRAS="[semantic]"' > ~/.config/zotero-mcp/plugin.env
uvx --from "zotero-mcp-server[semantic]" zotero-mcp update-db   # slow; --fulltext for more
uvx --from "zotero-mcp-server[semantic]" zotero-mcp db-status
```

The default embedding model is a local MiniLM — free, no API key. The index lives in `~/.config/zotero-mcp/chroma_db/`; switching embedding models needs `update-db --force-rebuild`.

## Toolsets

`ZOTERO_MCP_TOOLSETS` in `client_env` selects which optional groups load. Additive (`scite,feeds`) and subtractive (`all,-scite`) forms both work; unknown names fail at startup. Unset gives core plus `libraries`, `search-admin`, `pdf-geometry`. Disabled tools are genuinely absent rather than hidden, so this is also a way to keep the tool list short.

## Smoke test

The launcher hardcodes `serve`, so there is no `--help` path. Drive an MCP handshake through it instead:

```sh
printf '%s\n' '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"smoke","version":"0"}}}' \
  | plugins/zotero/scripts/launch-zotero.sh | head -1
```

A JSON-RPC `result` with `"serverInfo":{"name":"Zotero",...}` means the chain resolves. The first run downloads the package (~30 s).

Without the `[semantic]` extra the server also logs a one-line `chromadb is required for semantic search` warning to stderr at startup. That is expected on a base install and does not stop the server.

## Files

- `.claude-plugin/plugin.json` — plugin metadata.
- `.mcp.json` — MCP server declaration (local stdio, via the launcher; no env, no secrets).
- `scripts/launch-zotero.sh` — runtime fallback wrapper (`uvx` → `pipx run`), sources `plugin.env`.
- `commands/setup.md` — the `/zotero:setup` slash command.
