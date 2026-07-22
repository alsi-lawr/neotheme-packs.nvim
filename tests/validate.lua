local M = {}
local slug = "^[a-z0-9]+[a-z0-9-]*$"
local simplified = {
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
}
local full = {
	surface = { "deepest", "dark", "base", "raised", "selected", "border", "muted", "addition", "error" },
	text = { "primary", "bright", "strong", "muted", "on_accent", "on_error" },
	syntax = {
		"comment",
		"string",
		"keyword",
		"function_name",
		"type",
		"property",
		"literal",
		"operator",
		"punctuation",
		"regexp",
		"special",
		"attribute",
		"tag",
	},
	diagnostic = { "error", "warning", "information", "hint", "success" },
	markup = {
		"heading_1",
		"heading_2",
		"heading_3",
		"heading_4",
		"heading_5",
		"heading_6",
		"quote",
		"math",
		"link",
		"link_label",
		"raw",
		"list",
		"checked",
		"unchecked",
	},
	version_control = { "added", "changed", "removed", "ignored", "conflict" },
	ui = { "accent", "cursor", "directory", "search", "current_search", "match", "focus" },
}

local function fail(message)
	error(message, 0)
end

local function exact(value, fields, path)
	if type(value) ~= "table" then
		fail(path .. " must be a table")
	end
	local expected = {}
	for _, field in ipairs(fields) do
		expected[field] = true
	end
	for field in pairs(value) do
		if not expected[field] then
			fail(path .. " has unknown field " .. tostring(field))
		end
	end
	for field in pairs(expected) do
		if value[field] == nil then
			fail(path .. " is missing field " .. field)
		end
	end
end

local function safe(path)
	return type(path) == "string" and path ~= "" and path:sub(1, 1) ~= "/" and not path:find("..", 1, true)
end

local function bytes(path)
	local descriptor, message = vim.uv.fs_open(path, "r", 438)
	if not descriptor then
		fail(tostring(message))
	end
	local stat = assert(vim.uv.fs_fstat(descriptor))
	local value = assert(vim.uv.fs_read(descriptor, stat.size, 0))
	vim.uv.fs_close(descriptor)
	return value
end

local function validate_palette(theme, name)
	if theme.mode == "simplified" then
		exact(theme.palette, simplified, "palette " .. name)
		for field, color in pairs(theme.palette) do
			if type(color) ~= "string" or not color:match("^#%x%x%x%x%x%x$") then
				fail("invalid color " .. field)
			end
		end
		return
	end
	if theme.mode ~= "full" then
		fail("invalid palette mode")
	end
	exact(theme.palette, vim.tbl_keys(full), "palette " .. name)
	for category, fields in pairs(full) do
		exact(theme.palette[category], fields, "palette " .. name .. "." .. category)
		for field, color in pairs(theme.palette[category]) do
			if type(color) ~= "string" or not color:match("^#%x%x%x%x%x%x$") then
				fail("invalid color " .. category .. "." .. field)
			end
		end
	end
end

local function validate_themes(themes, theme_names)
	if type(themes) ~= "table" or vim.tbl_isempty(themes) then
		fail("themes are required")
	end
	for name, theme in pairs(themes) do
		if type(name) ~= "string" or not name:match(slug) or theme_names[name] then
			fail("theme collision or invalid name " .. tostring(name))
		end
		theme_names[name] = true
		exact(theme, { "background", "mode", "palette" }, "theme " .. name)
		if theme.background ~= "dark" and theme.background ~= "light" then
			fail("invalid background")
		end
		validate_palette(theme, name)
	end
end

function M.provider(provider)
	exact(provider, { "version", "provider", "packs" }, "provider")
	if provider.version ~= 1 or provider.provider ~= "neotheme-packs" then
		fail("invalid provider identity")
	end
	local theme_names = { custom = true }
	for key, pack in pairs(provider.packs) do
		if type(key) ~= "string" or not key:match(slug) then
			fail("invalid family key")
		end
		exact(pack, { "family", "themes" }, "runtime pack " .. key)
		if pack.family ~= key then
			fail("runtime family does not match key")
		end
		validate_themes(pack.themes, theme_names)
	end
	return true
end

function M.family(pack, key, root, upstream)
	exact(pack, {
		"schema",
		"family",
		"source_url",
		"revision",
		"spdx",
		"copyright_state",
		"copyright_notice",
		"license_file",
		"compromises",
		"sources",
		"themes",
	}, "authoritative pack " .. key)
	if type(pack.schema) ~= "number" or pack.schema % 1 ~= 0 or pack.schema ~= 1 then
		fail("invalid pack schema")
	end
	if pack.family ~= key then
		fail("pack family does not match key")
	end
	for _, field in ipairs({ "source_url", "revision", "spdx" }) do
		if type(pack[field]) ~= "string" or pack[field] == "" then
			fail(field .. " must be a string")
		end
	end
	if not pack.spdx:match("^[A-Za-z0-9]+[A-Za-z0-9%.%-]*$") then
		fail("invalid SPDX identifier")
	end
	if pack.copyright_state ~= "provided" and pack.copyright_state ~= "upstream-not-provided" then
		fail("invalid copyright state")
	end
	if
		type(pack.copyright_notice) ~= "string"
		or (pack.copyright_state == "provided" and pack.copyright_notice == "")
		or (pack.copyright_state == "upstream-not-provided" and pack.copyright_notice ~= "")
	then
		fail("copyright notice does not match state")
	end
	if not safe(pack.license_file) then
		fail("unsafe license path")
	end
	local license = root .. "/" .. pack.license_file
	if not vim.uv.fs_stat(license) or #bytes(license) < 100 then
		fail("complete license is required")
	end
	if type(pack.compromises) ~= "table" or #pack.compromises == 0 then
		fail("compromises are required")
	end
	if type(pack.sources) ~= "table" or #pack.sources == 0 then
		fail("sources are required")
	end
	for index, source in ipairs(pack.sources) do
		exact(source, { "path", "sha256" }, "source " .. index)
		if
			not safe(source.path)
			or type(source.sha256) ~= "string"
			or not source.sha256:match("^[0-9a-f]+$")
			or #source.sha256 ~= 64
		then
			fail("invalid source record")
		end
		if upstream then
			local source_path = upstream .. "/" .. key .. "/" .. source.path
			if not vim.uv.fs_stat(source_path) then
				fail("missing pinned source " .. source_path)
			end
			if vim.fn.sha256(bytes(source_path)) ~= source.sha256 then
				fail("source checksum mismatch " .. source_path)
			end
		end
	end
	validate_themes(pack.themes, {})
	return true
end

return M
