#!/usr/bin/env sh
set -eu

try() { command -v "$1" >/dev/null 2>&1; }

if try bunx; then
  exec bunx intelephense "$@"
fi
if try pnpm; then
  exec pnpm dlx intelephense -- "$@"
fi
if try npx; then
  exec npx -y intelephense -- "$@"
fi

cat >&2 <<EOF
error: none of bunx / pnpm / npx found on PATH
tried to launch: intelephense $*
install one of:
  - https://bun.sh
  - https://pnpm.io
  - https://nodejs.org
EOF
exit 127
