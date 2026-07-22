# neotheme-packs.nvim

Opt-in curated themes for
[neotheme.nvim](https://github.com/alsi-lawr/neotheme.nvim).

## Installation

With [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
	"alsi-lawr/neotheme.nvim",
	lazy = false,
	priority = 1000,
	dependencies = {
		"alsi-lawr/neotheme-packs.nvim",
	},
	config = function()
		require("neotheme").setup({
			palette_packs = {
				{ provider = "neotheme_packs", include = "*" },
			},
		})
		vim.cmd.colorscheme("neotheme")
	end,
}
```

Installing the dependency alone does not add themes; `palette_packs` opts in. See
[Palette Providers](https://github.com/alsi-lawr/neotheme.nvim/wiki/Palette-Providers) for family
selection and behaviour.

Palette values come from pinned upstream revisions. Source hashes, licenses, and mapping notes are
stored with each family. See
[Palette Pack Maintenance](https://github.com/alsi-lawr/neotheme.nvim/wiki/Palette-Pack-Maintenance)
for the data format and update process.

## Development

Run `./tests/run.sh` and `stylua --check lua tests`. Family notes are under [`docs/`](docs/), and
complete upstream license texts are under [`licenses/`](licenses/).

## License

Repository code is MIT licensed; see [LICENSE](LICENSE). Upstream palettes retain their respective
licenses under [`licenses/`](licenses/).
