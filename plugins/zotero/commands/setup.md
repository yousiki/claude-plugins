---
description: Configure the Zotero MCP server — probe runtime, pick local or web API, write ~/.config/zotero-mcp config.
argument-hint: "[local|web|hybrid]"
allowed-tools: Bash, Read, Write, AskUserQuestion
---

Configure the `zotero` MCP server for this machine. Work through the steps below in
order and stop at the first one that fails, reporting what the user has to fix.

`$ARGUMENTS`, when present, preselects the connection mode (`local`, `web`, or
`hybrid`) — skip step 4's question in that case.

Background you need: the server (`zotero-mcp serve`) reads its Zotero credentials
from the process environment. At startup it applies, as *defaults only*, the
`client_env` map from `~/.config/zotero-mcp/config.json`; real environment
variables always win. Writing that file is the whole job of this command. The
plugin's `.mcp.json` deliberately carries no `env` block, so nothing secret ever
lands in the plugin repo.

## 1. Probe the Python runtime

```sh
command -v uvx || command -v pipx
```

If neither is present, stop. Tell the user to install one:

- <https://docs.astral.sh/uv/> (provides `uvx`) — recommended
- <https://pipx.pypa.io/>

## 2. Warm the package cache

```sh
uvx --from zotero-mcp-server zotero-mcp version
```

(With `pipx` instead: `pipx run --spec zotero-mcp-server zotero-mcp version`.)

This takes ~30 s the first time. Doing it here means the download happens visibly,
rather than looking like a hang the first time Claude Code connects to the server.
Report the version it prints.

Note for yourself: the PyPI distribution is `zotero-mcp-server`. The name
`zotero-mcp` on PyPI is a **different, unrelated project** — never resolve it that
way.

## 3. Detect the local Zotero instance

```sh
ls -l ~/Zotero/zotero.sqlite 2>/dev/null
curl -s -m 3 -o /dev/null -w '%{http_code}\n' 'http://localhost:23119/api/users/0/items?limit=1'
```

Quote the URL — `?` and `&` are glob characters in zsh.

`200` means Zotero 7+ is running with the local API enabled. Anything else means
either Zotero isn't running, or the local API is off (Zotero → Settings → Advanced →
"Allow other applications on this computer to communicate with Zotero"). Report
which of the two it looks like, but keep going — web mode doesn't need it.

## 4. Choose a connection mode

Unless `$ARGUMENTS` already picked one, ask with `AskUserQuestion`:

- **local** — reads straight from the running Zotero app. No credentials. The local
  API is **read-only**, so tools that add or modify items will fail.
- **web** — talks to api.zotero.org. Needs an API key and the numeric library ID
  from <https://www.zotero.org/settings/security#applications>. Works without Zotero
  running; read *and* write.
- **hybrid** — `ZOTERO_LOCAL=true` plus key and library ID: fast local reads, web-API
  writes. Best of both if the user wants the write tools.

## 5. Collect credentials (web and hybrid only)

Check whether the key is already exported:

```sh
[ -n "${ZOTERO_API_KEY:-}" ] && echo "ZOTERO_API_KEY already set in env" || echo "not set"
```

If it isn't set, ask the user for it — and warn first that anything they type in
chat is stored in the conversation transcript. Offer the private alternative: they
can type

```
! read -rs ZOTERO_API_KEY && export ZOTERO_API_KEY
```

directly in the Claude Code prompt, then re-run `/zotero:setup`.

Never echo the key back, and never pass it as a command-line argument — argv is
visible to every process on the machine via `ps`, and lands in shell history.
Read it from the environment inside the heredoc in the next step instead.

Also collect the numeric library ID (the user ID for a personal library, the group
ID for a group) and the library type (`user` or `group`).

## 6. Write `~/.config/zotero-mcp/config.json`

Merge into the existing file — do not overwrite it, since it may already hold a
`semantic_search` block with indexing state. Set only `client_env`:

```sh
mkdir -p ~/.config/zotero-mcp
ZOTERO_LOCAL_MODE=true python3 - <<'PY'
import json, os, pathlib

path = pathlib.Path.home() / ".config" / "zotero-mcp" / "config.json"
cfg = {}
if path.exists():
    try:
        cfg = json.loads(path.read_text()) or {}
    except json.JSONDecodeError:
        cfg = {}

env = {
    "ZOTERO_LOCAL": os.environ["ZOTERO_LOCAL_MODE"],
    # Keep the server from scavenging env out of any Claude Desktop config it
    # happens to find, which would silently override what we write here.
    "ZOTERO_NO_CLAUDE": "true",
}
for key in ("ZOTERO_API_KEY", "ZOTERO_LIBRARY_ID", "ZOTERO_LIBRARY_TYPE"):
    if os.environ.get(key):
        env[key] = os.environ[key]

cfg["client_env"] = env
path.write_text(json.dumps(cfg, indent=2) + "\n")
path.chmod(0o600)
print(f"wrote {path}")
PY
```

Set `ZOTERO_LOCAL_MODE` to `true` for local and hybrid, `false` for web, and pass
`ZOTERO_API_KEY` / `ZOTERO_LIBRARY_ID` / `ZOTERO_LIBRARY_TYPE` as environment
variables on the same line for web and hybrid.

Then confirm the result without leaking the key:

```sh
ls -l ~/.config/zotero-mcp/config.json
python3 -c "import json,pathlib;print(sorted(json.loads((pathlib.Path.home()/'.config/zotero-mcp/config.json').read_text())['client_env']))"
```

Do **not** shell out to `uvx ... zotero-mcp setup`. Its `find_executable()` runs
before the `--no-claude` branch and is unreliable inside an ephemeral uvx
environment, and its semantic-search prompts need a TTY.

## 7. Offer semantic search (optional)

Ask whether the user wants `zotero_semantic_search`. Be explicit about the cost: it
pulls chromadb, sentence-transformers and torch — on the order of gigabytes into the
uv cache — and indexing a real library takes many minutes.

If they accept:

```sh
mkdir -p ~/.config/zotero-mcp
printf '%s\n' 'ZOTERO_MCP_EXTRAS="[semantic]"' > ~/.config/zotero-mcp/plugin.env
```

The launcher sources that file, so the server then resolves as
`zotero-mcp-server[semantic]`.

Add the embedding config to `config.json` with the same merge-then-write pattern as
step 6, setting `cfg.setdefault("semantic_search", {})["embedding_model"] = "default"`
— the default is a local MiniLM model, free and needing no API key. (OpenAI, Gemini
and Ollama backends exist; only reach for them if the user asks.)

Then build the index as a **background** Bash task:

```sh
uvx --from "zotero-mcp-server[semantic]" zotero-mcp update-db
```

When it finishes, report the outcome of:

```sh
uvx --from "zotero-mcp-server[semantic]" zotero-mcp db-status
```

## 8. Finish

Tell the user to run `/mcp` to reconnect the `zotero` server so it picks up the new
config, then verify by calling `zotero_get_collections`.

If they want the optional tool groups (`scite`, `duplicates`, `discovery`, `feeds`,
`relations` — all off by default), mention that `ZOTERO_MCP_TOOLSETS` can be added to
`client_env` in the same config file, e.g. `"all,-scite"`.
