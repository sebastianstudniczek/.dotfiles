local hollow = require("hollow")

hollow.config.set({
	default_domain = "UbuntuWSL",
	fonts = {
		family = "JetBrains Mono Nerd Font",
	},
	theme = {
		terminal = {
			background = "#191A1C",
		},
	},
	top_bar_mode = "tabs",
	load_default_keymaps = false,
})

hollow.keymap.default("<leader>p", "command_palette", { desc = "command palette" })

hollow.ui.topbar.configure({
	height = 0,
})
