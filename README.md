# neotheme-packs.nvim

Local, opt-in curated palette data for [neotheme.nvim](https://github.com/alsi-lawr/neotheme.nvim).
This repository is under preparation, has no remote, and has not been published. Repository
creation, remote configuration, and publication remain separate human-authorised work.

## Inventory

The pack contains only the five requested families and 16 variants:

- Kanagawa: Wave, Dragon, and Lotus.
- Rosé Pine: Main, Moon, and Dawn.
- Solarized: Dark and Light.
- Tokyo Night: Night, Storm, Moon, and Day.
- Catppuccin: Latte, Frappé, Macchiato, and Mocha.

Everforest, Nord, Gruvbox, and Monokai are deliberately absent.

## Native data contract

Each `lua/neotheme_packs/families/<family>.lua` file is the sole authority for that family. It is a
strict, data-only native Lua module returning:

- `schema = 1`, a matching family slug, upstream URL, immutable revision, and SPDX identifier;
- `copyright_state = "provided"` with an exact non-empty notice, or
  `"upstream-not-provided"` with an empty notice;
- a repository-relative complete license path;
- non-empty semantic compromises and pinned source records containing safe paths and lowercase
  SHA-256 values;
- keyed themes with exact `background`, `mode = "simplified"|"full"`, and a complete palette.

Simplified palettes are the exact flat 24-field Neotheme schema. Full palettes contain all 59 roles
in their seven exact categories. Values are `#RRGGBB` tokens. Family and theme names are lowercase
ASCII slugs and theme names are globally unique.

The hand-maintained `lua/neotheme_packs.lua` index requires each authoritative module and projects
only `{ family, themes }` into runtime provider schema v1. Provenance does not leak into the strict
runtime pack records. There is no compiler, TOML, Python, generated duplicate, or runtime parser;
native Lua/Neovim is the only runtime mechanism.

## Add or update a family

1. Select an immutable upstream revision and cache the exact source and license bytes without
   editing them.
2. Record every source path and SHA-256 in one authoritative family module. Preserve the complete
   pinned license, exact SPDX identifier, and exact notice; when upstream supplies no project
   notice, record that absence instead of inventing a holder.
3. Map only exact pinned colors. Choose Simplified for primitive palettes and Full when upstream
   exposes directly representable semantics. Document every best-fit alias, transform fan-out, or
   unrepresentable role without describing an approximation as an exact semantic assignment.
4. Add the family slug to the small provider index and add exact expected variants/backgrounds to
   `tests/pack.lua`.
5. Run native validation and inspect the diff before committing the family as one coherent change.

## Validation

Validate schema, provider projection, collisions, licenses, copyright state, inventory, and palette
completeness:

```sh
./tests/run.sh
stylua --check lua tests
git diff --check
```

Supply the cache root to additionally hash every pinned source byte and compare it with the
authoritative records:

```sh
NEOTHEME_PACK_UPSTREAM=/path/to/upstream-cache ./tests/run.sh
```

The cache layout is `<root>/<family>/<recorded-source-path>`. A missing or changed byte fails
validation before provenance is claimed.
