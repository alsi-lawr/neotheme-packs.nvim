#!/bin/sh
set -eu
root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
NVIM_LOG_FILE="${TMPDIR:-/tmp}/neotheme-packs-test.log" \
  NEOTHEME_PACK_ROOT="$root" \
  nvim --headless -u NONE -i NONE -n -l "$root/tests/pack.lua"
