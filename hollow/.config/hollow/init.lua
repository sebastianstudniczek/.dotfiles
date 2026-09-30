local hollow = require("hollow")

local config = {
	-- domains = {
	-- 	UbuntuWSL = {
	-- 		shell = "wsl -d Ubuntu",
	-- 		wsl_distro = "Ubuntu",
	-- 	},
	-- },
	default_domain = "UbuntuWSL",
	domains = {
		UbuntuWSL = {
			default_cwd = "/home/eddyi0202",
		},
	},
	fonts = {
		family = "JetBrains Mono Nerd Font",
	},
	theme = {
		terminal = {
			background = "#191A1C",
		},
	},
	debug_overlay = false,
	-- top_bar_mode = "tabs",
}

local use_tmux = false
if use_tmux then
	config.load_default_keymaps = false
	hollow.ui.topbar.configure({
		height = 0,
	})
else
	hollow.keymap.set_leader("<C-a>", { timeout_ms = 1200 })
	hollow.keymap.set("<leader>k", "workspace_switcher")
	hollow.keymap.set("<leader>c", "new_tab")
	hollow.keymap.set("<leader>x", "close_pane")
	hollow.keymap.set("<leader>p", "prev_tab")
	hollow.keymap.set("<leader>n", "next_tab")
	-- hollow.keymap.default("<leader><S-\\>", "split_vertical")
	hollow.keymap.set("<C-S-p>", "command_palette", { desc = "command palette" })
	--
	-- tODO: Missing support for querying by index
	for i = 1, 9 do
		hollow.keymap.set("<leader>" .. i, function()
			-- 0 based index
			hollow.term.focus_tab_by_index(i - 1)
		end)
	end

	-- conf/init.lua
	require("hollow.plugins").setup({
		plugins = {
			"~/repos/hollow-workmux",
		},
	})

	-- TODO: Fetch it from env variable?
	local home_dir = "/home/eddyi0202"

	hollow.ui.workspace.configure({
		name_column_width = 50,
		format_item = function(ws)
			local icon
			if ws.source == "zoxide" and not ws.is_open then
				icon = "📁  "
			elseif ws.is_open then
				icon = "🪟  "
			end

			return {
				hollow.ui.span(icon or "   "),
				-- TODO: some helper for getting home folder
				hollow.ui.span(ws.name:gsub("/home/eddyi0202", "~"), { bold = ws.is_active }),
				hollow.ui.span(ws.cwd and ("  " .. ws.cwd) or "", { fg = "#727169" }),
			}
		end,
		sources = {
			-- {
			-- 	name = "predefined",
			-- },
			{
				name = "zoxide",
				domain = "UbuntuWSL",
				items = function()
					local queried_items = {}

					local success, stdout, stderr = hollow.term.run_domain_process({ "zoxide", "query", "-l" })
					if not success then
						hollow.log("Failed to query zoxide: " .. stderr)
						return {}
					end

					for line in stdout:gmatch("[^\n]+") do
						-- TODO: Sanitize this
						table.insert(queried_items, { source = "zoxide", name = line, id = line, cwd = line })
						if #queried_items > 20 then
							return queried_items
						end
					end

					return queried_items
				end,
			},
			{
				name = "Base",
				domain = "UbuntuWSL",
				cwd_resolver = "wsl_unc",
				roots = {
					"\\\\wsl$\\Ubuntu\\home\\eddyi0202\\repos",
				},
			},
		},
	})
end

hollow.config.set(config)

-- hollow.ui.sidebar.mount(hollow.ui.sidebar.new({
-- 	side = "right",
-- 	width = 32,
-- 	render = function(ctx)
-- 		local tab = ctx.term.tab
-- 		if not tab then
-- 			return hollow.ui.column({})
-- 		end
--
-- 		local rows = {
-- 			hollow.ui.row({
-- 				hollow.ui.text("panes in " .. (tab.title or "<tab>"), { bold = true, fg = "#7e9cd8" }),
-- 			}, { fill_bg = "#1f1f28" }),
-- 		}
--
-- 		for i, p in ipairs(tab.panes) do
-- 			local label = p.title
-- 				or p.foreground_process
-- 				or hollow.util.basename(p.cwd or "")
-- 				or string.format("pane %d", i)
-- 			rows[#rows + 1] = hollow.ui.row({
-- 				hollow.ui.text(p.is_focused and "* " or "  "),
-- 				hollow.ui.text(label, { bold = p.is_focused }),
-- 			})
-- 		end
--
-- 		return hollow.ui.column(rows)
-- 	end,
-- }))

-- workmux plugin
