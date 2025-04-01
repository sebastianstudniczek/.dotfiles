local wezterm = require("wezterm");
local config = wezterm.config_builder();
local act = wezterm.action;
local mux = wezterm.mux

config = {
	adjust_window_size_when_changing_font_size = false,
	window_close_confirmation = "NeverPrompt",
	window_decorations = "RESIZE|INTEGRATED_BUTTONS",
	font_size = 10,
	color_scheme = "tokyonight_storm",
	font = wezterm.font("JetBrainsMono Nerd Font"),
	hide_tab_bar_if_only_one_tab = true,
	use_fancy_tab_bar = false,
	tab_bar_at_bottom = false,
	tab_max_width = 500
}

config.default_prog = { 'pwsh.exe' }
config.default_domain = "WSL:Ubuntu"

wezterm.on("gui-startup", function()
	local _, _, window = mux.spawn_window({})
	window:gui_window():maximize()
end)

return config;
