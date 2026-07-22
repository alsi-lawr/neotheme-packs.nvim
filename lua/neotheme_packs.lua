local families = {}
local packs = {}

for _, family in ipairs(families) do
	local authoritative = require("neotheme_packs.families." .. family)
	packs[family] = {
		family = authoritative.family,
		themes = authoritative.themes,
	}
end

return {
	version = 1,
	provider = "neotheme-packs",
	packs = packs,
}
