return {
  {
    "GustavEikaas/easy-dotnet.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "folke/snacks.nvim" },
    config = function()
      local dotnet = require("easy-dotnet")

      dotnet.setup({
        picker = "snacks",

        vim.keymap.set("n", "<leader>cb", function()
          dotnet.build_solution()
        end, {
          desc = "Build soltion",
        }),
      })
    end,
  },
  {
    "seblyng/roslyn.nvim",
    ft = "cs",
    ---@module 'roslyn.config'
    ---@type RoslynNvimConfig
    opts = {
      -- your configuration comes here; leave empty for default settings
      -- NOTE: You must configure `cmd` in `config.cmd` unless you have installed via mason
    },
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "csharpier",
        "netcoredbg",
      },
      registries = {
        "github:mason-org/mason-registry",
        "github:Crashdummyy/mason-registry",
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "c_sharp" },
    },
  },
  {
    "nvimtools/none-ls.nvim",
    optional = true,
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.sources = opts.sources or {}
      table.insert(opts.sources, nls.builtins.formatting.csharpier)
    end,
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        cs = { "csharpier" },
      },
      formatters = {
        csharpier = {
          command = "csharpier",
          args = {
            "format",
            "--write-stdout",
          },
        },
      },
    },
  },
  {
    "nsidorenco/neotest-vstest",
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "neotest-vstest",
    },
    opts = {
      adapters = {
        ["neotest-vstest"] = {},
      },
    },
  },
}
