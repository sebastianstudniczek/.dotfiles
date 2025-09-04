return {
  {
    "GustavEikaas/easy-dotnet.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "folke/snacks.nvim" },
    config = function()
      local dotnet = require("easy-dotnet")

      dotnet.setup({
        picker = "snacks",
        test_runner = {
          viewmode = "vsplit",
          vsplit_widht = 70,
          mappings = {
            run_test_from_buffer = { lhs = "<leader>tr", desc = "Run test from buffer" },
            run_test = { lhs = "<leader>tr", desc = "Run test" },
            peek_stracktrace = { lhs = "<leader>tp" },
          },
        },

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
