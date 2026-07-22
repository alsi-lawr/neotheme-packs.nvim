local root = assert(os.getenv("NEOTHEME_PACK_ROOT"))
vim.opt.runtimepath:prepend(root)
local validate = dofile(root .. "/tests/validate.lua")
local provider = require("neotheme_packs")

assert(validate.provider(provider))
local expected = {
	["catppuccin-latte"] = "light",
	["catppuccin-frappe"] = "dark",
	["catppuccin-macchiato"] = "dark",
	["catppuccin-mocha"] = "dark",
	["kanagawa-wave"] = "dark",
	["kanagawa-dragon"] = "dark",
	["kanagawa-lotus"] = "light",
	["rose-pine"] = "dark",
	["rose-pine-moon"] = "dark",
	["rose-pine-dawn"] = "light",
	["solarized-dark"] = "dark",
	["solarized-light"] = "light",
	["tokyonight-night"] = "dark",
	["tokyonight-storm"] = "dark",
	["tokyonight-moon"] = "dark",
	["tokyonight-day"] = "light",
}
local actual = {}
for _, pack in pairs(provider.packs) do
	for name, theme in pairs(pack.themes) do
		actual[name] = theme.background
	end
end
assert(vim.deep_equal(expected, actual), "provider inventory and backgrounds must match all 16 variants")
for _, family in ipairs({ "everforest", "nord", "gruvbox", "monokai" }) do
	assert(provider.packs[family] == nil, "excluded family must remain absent: " .. family)
end
for family, runtime in pairs(provider.packs) do
	local authoritative = require("neotheme_packs.families." .. family)
	assert(validate.family(authoritative, family, root, os.getenv("NEOTHEME_PACK_UPSTREAM")))
	assert(
		vim.deep_equal(vim.tbl_keys(runtime), { "family", "themes" })
			or vim.deep_equal(vim.tbl_keys(runtime), { "themes", "family" })
	)
	assert(runtime.family == authoritative.family)
	assert(vim.deep_equal(runtime.themes, authoritative.themes))
end

local flat = {}
for _, field in ipairs({
	"surface_deepest",
	"surface_dark",
	"surface_base",
	"surface_raised",
	"surface_selected",
	"surface_border",
	"surface_muted",
	"surface_addition",
	"surface_error",
	"text_primary",
	"text_bright",
	"text_strong",
	"text_muted",
	"text_on_accent",
	"text_on_error",
	"syntax_comment",
	"syntax_string",
	"syntax_keyword",
	"syntax_function_name",
	"syntax_type",
	"syntax_property",
	"syntax_literal",
	"diagnostic_error",
	"version_control_conflict",
}) do
	flat[field] = "#112233"
end
local fixture = {
	version = 1,
	provider = "neotheme-packs",
	packs = {
		sample = {
			family = "sample",
			themes = {
				["sample-dark"] = { background = "dark", mode = "simplified", palette = flat },
			},
		},
	},
}
assert(validate.provider(fixture))
local authoritative = {
	schema = 1,
	family = "sample",
	source_url = "https://example.invalid/sample",
	revision = "immutable-test-revision",
	spdx = "MIT",
	copyright_state = "upstream-not-provided",
	copyright_notice = "",
	license_file = "LICENSE",
	compromises = { "Synthetic validation fixture only." },
	sources = {
		{ path = "source.lua", sha256 = string.rep("0", 64) },
	},
	themes = fixture.packs.sample.themes,
}
assert(validate.family(authoritative, "sample", root, nil))
local invalid_authoritative = vim.deepcopy(authoritative)
invalid_authoritative.license_file = "../LICENSE"
assert(
	not pcall(validate.family, invalid_authoritative, "sample", root, nil),
	"unsafe authoritative license path must fail"
)
local malformed = vim.deepcopy(fixture)
malformed.packs.sample.themes["sample-dark"].palette.syntax_literal = nil
assert(not pcall(validate.provider, malformed), "incomplete flat simplified palette must fail")

local collision = vim.deepcopy(provider)
if not vim.tbl_isempty(collision.packs) then
	local first = next(collision.packs)
	collision.packs.collision = vim.deepcopy(collision.packs[first])
	collision.packs.collision.family = "collision"
	assert(not pcall(validate.provider, collision), "duplicate theme names must fail")
end
