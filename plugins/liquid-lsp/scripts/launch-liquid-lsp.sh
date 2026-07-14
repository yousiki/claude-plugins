#!/usr/bin/env sh
set -eu

try() { command -v "$1" >/dev/null 2>&1; }

if try bunx; then
  exec bunx -p @shopify/cli shopify theme language-server "$@"
fi
if try pnpm; then
  exec pnpm --package=@shopify/cli dlx shopify -- theme language-server "$@"
fi
if try npx; then
  exec npx -y --package=@shopify/cli shopify -- theme language-server "$@"
fi

cat >&2 <<EOF
error: none of bunx / pnpm / npx found on PATH
tried to launch: shopify theme language-server (from @shopify/cli)
install one of:
  - https://bun.sh
  - https://pnpm.io
  - https://nodejs.org
EOF
exit 127
