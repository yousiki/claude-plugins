#!/usr/bin/env sh
# Launch the zotero-mcp MCP server with runtime fallback.
#
# PyPI dist is `zotero-mcp-server`; the bin is `zotero-mcp`, so uvx/pipx need an
# explicit "--from"/"--spec". Note that `zotero-mcp` on PyPI is a *different*,
# unrelated project (kujenga/zotero-mcp) — never resolve the dist by that name.
#
# Optional overrides, sourced from ~/.config/zotero-mcp/plugin.env:
#   ZOTERO_MCP_EXTRAS  - e.g. "[semantic]" or "[all]"  (default: base install)
#   ZOTERO_MCP_VERSION - e.g. "==0.9.1" to pin          (default: latest)
#   ZOTERO_MCP_PYTHON  - interpreter for uvx            (default: 3.14)
# Zotero credentials are NOT set here. The server self-configures at startup
# from ~/.config/zotero-mcp/config.json (`client_env`); see /zotero:setup.
set -eu

PLUGIN_ENV="${XDG_CONFIG_HOME:-$HOME/.config}/zotero-mcp/plugin.env"
if [ -f "$PLUGIN_ENV" ]; then
  # shellcheck source=/dev/null
  . "$PLUGIN_ENV"
fi

SPEC="zotero-mcp-server${ZOTERO_MCP_EXTRAS:-}${ZOTERO_MCP_VERSION:-}"

# "3.14" resolves to the newest 3.14.x uv knows about, and uv downloads a
# managed interpreter when the host has none — so this stays zero-install.
# Deliberately not passed to pipx: pipx cannot provision an interpreter, so
# pinning there would turn a working fallback into a hard failure.
PYVER="${ZOTERO_MCP_PYTHON:-3.14}"

try() { command -v "$1" >/dev/null 2>&1; }

if try uvx; then
  exec uvx --python "$PYVER" --from "$SPEC" zotero-mcp serve --transport stdio
fi
if try pipx; then
  exec pipx run --spec "$SPEC" zotero-mcp serve --transport stdio
fi

cat >&2 <<EOF
error: no supported Python runtime found on PATH
tried to launch: zotero-mcp (from $SPEC)
install one of:
  - https://docs.astral.sh/uv/ (provides uvx)
  - https://pipx.pypa.io/
EOF
exit 127
