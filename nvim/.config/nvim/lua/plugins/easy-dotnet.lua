return {
  {
    "GustavEikaas/easy-dotnet.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "folke/snacks.nvim" },
    config = function()
      local dotnet = require("easy-dotnet")

      local netcoreDbgExec = vim.fn.has("win32") == 1 and "netcoredbg.cmd" or "netcoredbg"

      dotnet.setup({
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
            local fidget_handler = require("fidget.progress").handle.create({
              title = start_event.job.name,
              message = start_event.job.name,
              lsp_client = {
                name = "easy-dotnet",
              },
            })

            ---@param finished_event easy-dotnet.Job.Event
            return function(finished_event)
              if finished_event.success then
                fidget_handler.message = finished_event.job.on_success_text
              else
                fidget_handler.message = finished_event.job.on_error_text
              end
              fidget_handler:finish()
            end
          end,
        },
      })

      vim.keymap.set("n", "<leader>cb", function()
        dotnet.build_solution_quickfix()
      end, {
        desc = "Build solution",
      })
    end,
  },
}
