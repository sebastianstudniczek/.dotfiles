local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action
local mux = wezterm.mux

local keys = {}

config = {
	front_end = "WebGpu",
	adjust_window_size_when_changing_font_size = false,
	window_close_confirmation = "NeverPrompt",
	window_decorations = "RESIZE",
	font_size = 10,
	color_scheme = "Tokyo Night",
	font = wezterm.font("Iosevka Nerd Font"),
	hide_tab_bar_if_only_one_tab = false,
	use_fancy_tab_bar = false,
	tab_bar_at_bottom = true,
	tab_max_width = 500,
	default_cursor_style = "SteadyBar",
	max_fps = 120,
}

for _, gpu in ipairs(wezterm.gui.enumerate_gpus()) do
	if gpu.backend == "Dx12" and gpu.device_type == "DiscreteGpu" then
		config.webgpu_preferred_adapter = gpu
		break
	end
end

-- Match Mica effect
config.window_frame = {
	active_titlebar_bg = "rgba(0, 0, 0, 0)",
}

-- FG color to match rose pine theme
config.colors = {
	background = "#191A1C",
	tab_bar = {
		inactive_tab = {
			bg_color = "rgba(0, 0, 0, 0.26)",
			fg_color = "#aa92ca",
		},
		active_tab = {
			bg_color = "rgba(0, 0, 0, 0)",
			fg_color = "#f6c177",
		},
		background = "rgba(0, 0, 0, 0.26)",
	},
}

-- print the workspace name at the upper right
wezterm.on("update-right-status", function(window, pane)
	window:set_right_status(wezterm.format({
		{ Foreground = { Color = "#aa92ca" } },
		{ Text = window:active_workspace() },
	}))
end)

local sessionizer = wezterm.plugin.require("https://github.com/mikkasendke/sessionizer.wezterm")
local sessionizer_zoxide = wezterm.plugin.require("https://github.com/mikkasendke/sessionizer-zoxide")
local history = wezterm.plugin.require("https://github.com/mikkasendke/sessionizer-history")

local PredefinedEntries = function()
	return function()
		return {
			{ label = "Dotfiles", id = wezterm.home_dir .. "\\.dotfiles" },
			{ label = "Repos", id = "D:\\" },
		}
	end
end

local sessionizer_schema = {
	options = {
		prompt = "Workspace to switch: ",
		callback = history.Wrapper(sessionizer.DefaultCallback),
	},
	{
		sessionizer.AllActiveWorkspaces({ filter_current = false, filter_default = false }),
		processing = sessionizer.for_each_entry(function(entry)
			entry.label = "🪟 " .. entry.label
		end),
	},

	{
		PredefinedEntries(),
		processing = sessionizer.for_each_entry(function(entry)
			entry.label = "⚙️ " .. entry.label
		end),
	},
	{
		sessionizer_zoxide.Zoxide({}),
		processing = sessionizer.for_each_entry(function(entry)
			entry.label = "📁 " .. entry.label
		end),
	},
	processing = sessionizer.for_each_entry(function(entry)
		entry.label = entry.label:gsub(wezterm.home_dir, "~")
	end),
}

config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
-- HACK: By default terminal is not recognizing this key combination, so we need to send it manually
table.insert(keys, { key = ".", mods = "CTRL", action = wezterm.action.SendKey({ key = ".", mods = "CTRL" }) })
table.insert(keys, { key = "k", mods = "LEADER", action = sessionizer.show(sessionizer_schema) })
table.insert(keys, { key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") })
table.insert(keys, { key = "x", mods = "LEADER", action = act.CloseCurrentTab({ confirm = false }) })
table.insert(keys, { key = "L", mods = "LEADER", action = history.switch_to_most_recent_workspace })

for i = 1, 9 do
	table.insert(keys, {
		key = tostring(i),
		mods = "LEADER",
		action = act.ActivateTab(i - 1),
	})
end

config.default_prog = { "pwsh.exe" }

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
	local _, second_pane, _ = window:spawn_tab({})

	mux.set_active_workspace("dotfiles")
end)

config.keys = keys
return config
