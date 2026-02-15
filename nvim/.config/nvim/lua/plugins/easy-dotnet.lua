return {
  {
    "GustavEikaas/easy-dotnet.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "folke/snacks.nvim" },
    config = function()
      local dotnet = require("easy-dotnet")

      local netcoreDbgExec = vim.fn.has("win32") == 1 and "netcoredbg.cmd" or "netcoredbg"

      local cfg = {
        lsp = {
          -- Use roslyn.nvim
          enabled = false,
        },
        --INFO: Snacks is somehow ignoring shellslash option and passing forward slash path
        --while using it as picker to choose dll to debug
        picker = "snacks",
        test_runner = {
          viewmode = "vsplit",
          vsplit_width = 70,
        },
        debugger = {
          bin_path = netcoreDbgExec,
          mappings = {
            open_variable_viewer = { lhs = "<leader>df", desc = "open variable viewer" },
          },
        },
        ---@type easy-dotnet.Notifications
        notifications = {
          handler = function(start_event)
            local is_project_loading = start_event.job.name:find("^Loading") ~= nil
            local title = is_project_loading and "Loading project..." or start_event.job.name
            local fidget_handler = require("fidget.progress").handle.create({
              title = title,
              message = title,
              lsp_client = {
                name = "easy-dotnet",
              },
            })

            ---@param finished_event easy-dotnet.Job.Event
            return function(finished_event)
              if finished_event.success then
                fidget_handler.message = is_project_loading and "Project loaded" or finished_event.job.on_success_text
              else
                fidget_handler.message = is_project_loading and "Project loading failed"
                  or finished_event.job.on_error_text
              end
              fidget_handler:finish()
            end
          end,
        },
      }

      if not vim.g.neotest_vstest_enabled then
        vim.keymap.set("n", "<leader>ts", "<cmd>Dotnet testrunner<CR>", {
          desc = "open testrunner (easy-dotnet)",
        })

        cfg.test_runner.mappings = vim.tbl_extend("force", cfg.test_runner.mappings or {}, {
          run_test_from_buffer = { lhs = "<leader>tr", desc = "Run nearest (easy-dotnet)" },
          debug_test_from_buffer = { lhs = "<leader>td", desc = "Debug nearest (easy-dotnet)" },
          run_all_tests_from_buffer = { lhs = "<leader>tt", desc = "Run File (easy-dotnet)" },
          peek_stack_trace_from_buffer = { lhs = "<leader>to", desc = "Show output (easy-dotnet)" },
        })
      end

      dotnet.setup(cfg)

      vim.keymap.set("n", "<leader>cb", function()
        dotnet.build_solution_quickfix()
      end, {
        desc = "Build solution",
      })
    end,
  },
}
