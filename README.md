# neotheme-packs.nvim

Local, opt-in curated palette data for [neotheme.nvim](https://github.com/alsi-lawr/neotheme.nvim).
This repository is under preparation and has not been published or assigned a remote.

Each `lua/neotheme_packs/families/*.lua` file is authoritative, strict, data-only Lua. The small
`lua/neotheme_packs.lua` index requires those family modules and returns provider schema v1. Neovim
parses no TOML and the pack has no runtime dependency beyond native Lua/Neovim.

Run native validation with `tests/run.sh`. To verify exact pinned bytes as well, set
`NEOTHEME_PACK_UPSTREAM=/path/to/upstream-cache` before running it.
