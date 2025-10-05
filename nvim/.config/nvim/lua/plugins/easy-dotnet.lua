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
      })

      vim.keymap.set("n", "<leader>cb", function()
        dotnet.build_solution_quickfix()
      end, {
        desc = "Build solution",
      })
    end,
  },
}
