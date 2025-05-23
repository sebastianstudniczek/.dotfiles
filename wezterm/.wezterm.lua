local wezterm = require("wezterm");
local config = wezterm.config_builder();
local act = wezterm.action;
local mux = wezterm.mux

local keys = {}

config = {
	adjust_window_size_when_changing_font_size = false,
	window_close_confirmation = "NeverPrompt",
	window_decorations = "RESIZE",
	font_size = 9,
	front_end = 'WebGpu',
	color_scheme = "rose-pine",
	font = wezterm.font("JetBrainsMono Nerd Font"),
	hide_tab_bar_if_only_one_tab = false,
	use_fancy_tab_bar = false,
	tab_bar_at_bottom = true,
	tab_max_width = 500,
	win32_system_backdrop = 'Mica',
	window_background_opacity = 0.0
}

-- Match Mica effect
config.window_frame = {
	active_titlebar_bg = 'rgba(0, 0, 0, 0)'
}

-- FG color to match rose pine theme
config.colors = {
	tab_bar = {
		inactive_tab = {
			bg_color = 'rgba(0, 0, 0, 0.26)',
			fg_color = '#aa92ca'
		},
		active_tab = {
			bg_color = 'rgba(0, 0, 0, 0)',
			fg_color = '#f6c177'
		},
		background = 'rgba(0, 0, 0, 0.26)'
	}
}

-- print the workspace name at the upper right
wezterm.on("update-right-status", function(window, pane)
	window:set_right_status(wezterm.format({
		{ Foreground = { Color = "#aa92ca" } },
		{ Text = window:active_workspace() }
	}))
end)
end)

-- Workspace switcher
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")

-- keymaps
-- timeout_milliseconds defaults to 1000 and can be omitted
-- mimic tmux
config.default_workspace = "~"
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }

table.insert(keys, { key = "s", mods = "LEADER", action = workspace_switcher.switch_workspace() })

config.default_prog = { 'pwsh.exe' }

wezterm.on("gui-startup", function()
	local _, _, window = mux.spawn_window({})
	window:gui_window():maximize()
end)

config.keys = keys;
return config;
