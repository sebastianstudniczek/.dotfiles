return {
  {
    "GustavEikaas/easy-dotnet.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "folke/snacks.nvim" },
    config = function()
      local dotnet = require("easy-dotnet")

      local netcoreDbgExec = vim.fn.has("win32") == 1 and "netcoredbg.cmd" or "netcoredbg"

      dotnet.setup({
        picker = "snacks",
        test_runner = {
          viewmode = "vsplit",
          vsplit_width = 70,
          mappings = {
            run_test_from_buffer = { lhs = "<leader>tr", desc = "Run test from buffer" },
            run_test = { lhs = "<leader>tr", desc = "Run test" },
            peek_stracktrace = { lhs = "<leader>tp" },
          },
        },
        debugger = {
          bin_path = netcoreDbgExec,
          mappings = {
            open_variable_viewer = { lhs = "<leader>df", desc = "open variable viewer" },
          },
        },
      })

        vim.keymap.set("n", "<leader>cb", function()
          dotnet.build_solution_quickfix()
        end, {
          desc = "Build solution",
        }),

        vim.keymap.set("n", "<leader>ts", function()
          dotnet.testrunner()
        end, {
          desc = "Show test runner",
        }),

        vim.keymap.set("n", "<leader>tb", function()
          dotnet.testrunner_refresh()
        end, {
          desc = "Refresh test runner",
        }),
      })
    end,
  },
}
