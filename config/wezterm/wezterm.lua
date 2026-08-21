local wezterm = require("wezterm")

-- Dark/light pair from the same family, so only the lightness changes.
local DARK = "Catppuccin Mocha"
local LIGHT = "Catppuccin Latte"

-- CMD+SHIFT+L flips the current window between them. Per-window and not
-- persisted: a new window starts at DARK again.
wezterm.on("toggle-theme", function(window, _pane)
	local overrides = window:get_config_overrides() or {}
	if overrides.color_scheme == LIGHT then
		overrides.color_scheme = DARK
	else
		overrides.color_scheme = LIGHT
	end
	window:set_config_overrides(overrides)
end)

return {
	-- JetBrains Mono renders all normal text unchanged; the Nerd Font is only
	-- a fallback for icon glyphs (oh-my-pi, etc.) that JetBrains Mono lacks.
	font = wezterm.font_with_fallback({
		"JetBrains Mono",
		"JetBrainsMono Nerd Font Mono",
	}),
	font_size = 18.0,
	-- WezTerm's default link detection requires a domain in the URL, so a
	-- file:///Users/... link never matched. Keep the defaults, add file://.
	-- Ctrl-click on such a link opens Finder at the file (this build's behavior).
	hyperlink_rules = (function()
		local rules = wezterm.default_hyperlink_rules()
		table.insert(rules, { regex = [[\bfile://[^\s\])]+]], format = "$0" })
		return rules
	end)(),
	enable_tab_bar = false,
	window_decorations = "RESIZE",
	color_scheme = DARK,
	-- Claude Code paints inline `code` as 256-colour index 153 (#afd7ff), a pale
	-- blue that sits too close to white to be legible for a colour-blind reader.
	-- Remap it to a warm amber: separated from white by BRIGHTNESS as well as
	-- hue, so the cue survives regardless of colour-vision type.
	colors = {
		indexed = {
			[153] = "#ffb86c",
		},
	},
	window_close_confirmation = "NeverPrompt",
	keys = {
		{
			key = "w",
			mods = "CMD",
			action = wezterm.action.CloseCurrentTab({ confirm = false }),
		},
		{
			key = "L",
			mods = "CMD|SHIFT",
			action = wezterm.action.EmitEvent("toggle-theme"),
		},
	},
}
