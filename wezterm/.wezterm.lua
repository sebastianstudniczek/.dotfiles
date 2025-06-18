local wezterm = require("wezterm");
local config = wezterm.config_builder();
local act = wezterm.action;
local mux = wezterm.mux

local keys = {}

-- local gpus = wezterm.gui.enumerate_gpus()
-- wezterm.log_info(gpus[1])
-- config.webgpu_preferred_adapter = gpus[1]

config = {
	adjust_window_size_when_changing_font_size = false,
	window_close_confirmation = "NeverPrompt",
	window_decorations = "RESIZE",
	font_size = 9,
	front_end = 'WebGpu',
	color_scheme = "rose-pine",
	-- font = wezterm.font 'Fira Code',
	hide_tab_bar_if_only_one_tab = false,
	use_fancy_tab_bar = false,
	tab_bar_at_bottom = true,
	tab_max_width = 500,
	win32_system_backdrop = 'Mica',
	window_background_opacity = 0.0,
	-- Run as WT so PSFzf is treating wezterm as capable terminal
	-- to display colorfull output and to properly use git helpers
	set_environment_variables = {
		WT_Session = 'Fake-Session'
	}
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

function basename(s)
	local programName = string.gsub(s, '(.*[/\\])(.*)(.exe)', '%2')
	return programName:gsub('.exe', '')
end

-- wezterm.on("update-right-status", function(window, pane)
-- 	wezterm.log_info(pane:get_foreground_process_info())
-- 	window:set_right_status(basename(pane:get_foreground_process_name()))
-- end)


wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	wezterm.log_info(tab.tab_title)
	local pane = tab.active_pane
	local program = pane:get_foreground_process_info()
	local title = basename(pane.foreground_process_name)

	return {
		{Text = " " .. tab.tab_id + 1 .. ":" .. title .. " "}
	}
end)

-- Workspace switcher
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")

-- keymaps
-- timeout_milliseconds defaults to 1000 and can be omitted
-- mimic tmux
config.default_workspace = "~"
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }

table.insert(keys, { key = "$", mods = "LEADER", action = wezterm.action.PromptInputLine({
	description = "Enter new name for workspace",
	action = wezterm.action_callback(function(window, pane, line)
			if line then 
				wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
			end
	end)
	})
})

table.insert(keys, { key = "k", mods = "CTRL", action = workspace_switcher.switch_workspace() })
table.insert(keys, { key = "t", mods = "CTRL", action = act.SpawnTab("CurrentPaneDomain") })
table.insert(keys, { key = "w", mods = "CTRL", action = act.CloseCurrentTab { confirm = false }})

for i = 1, 9 do
	table.insert(keys, {
		key = tostring(i),
		mods = "CTRL",
		action = act.ActivateTab(i - 1)
	})
end

workspace_switcher.workspace_formatter = function(label)
  return wezterm.format({
    { Foreground = { Color = "#f6c177" } },
    { Text = "󱂬: " .. label },
  })
end

config.default_prog = { 'pwsh.exe' }

wezterm.on("gui-startup", function(cmd)
	local args = {}
	if cmd then
		args = cmd.args
	end

	local dotfiles_path = wezterm.home_dir .. "/.dotfiles"
	local tab, build_pane, window = mux.spawn_window({
		workspace = "dotfiles",
		cwd = dotfiles_path,
		args = args,
	})
	build_pane:send_text("lazygit\n\r")
	local _, second_pane, _ = window:spawn_tab {}

	mux.set_active_workspace("dotfiles")
	window:gui_window():maximize()
end)


-- wezterm.on("gui-startup", function()
-- 	local _, _, window = mux.spawn_window({})
-- 	window:gui_window():maximize()
-- end)

config.keys = keys;
return config;
