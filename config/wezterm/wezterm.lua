local wezterm = require("wezterm")

return {
	-- JetBrains Mono renders all normal text unchanged; the Nerd Font is only
	-- a fallback for icon glyphs (oh-my-pi, etc.) that JetBrains Mono lacks.
	font = wezterm.font_with_fallback({
		"JetBrains Mono",
		"JetBrainsMono Nerd Font Mono",
	}),
	font_size = 18.0,
	enable_tab_bar = false,
	window_decorations = "RESIZE",
	color_scheme = "Catppuccin Mocha",
	window_close_confirmation = "NeverPrompt",
	keys = {
		{
			key = "w",
			mods = "CMD",
			action = wezterm.action.CloseCurrentTab({ confirm = false }),
		},
	},
}
