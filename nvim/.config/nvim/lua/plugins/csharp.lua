vim.lsp.config("roslyn", {
  settings = {
    ["csharp|inlay_hints"] = {
      csharp_enable_inlay_hints_for_implicit_object_creation = true,
      csharp_enable_inlay_hints_for_implicit_variable_types = true,
      csharp_enable_inlay_hints_for_lambda_parameter_types = true,
      csharp_enable_inlay_hints_for_types = true,
      dotnet_enable_inlay_hints_for_indexer_parameters = true,
      dotnet_enable_inlay_hints_for_literal_parameters = true,
      dotnet_enable_inlay_hints_for_object_creation_parameters = true,
      dotnet_enable_inlay_hints_for_other_parameters = true,
      dotnet_enable_inlay_hints_for_parameters = true,
      dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
      dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
      dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
    },
    ["csharp|code_lens"] = {
      dotnet_enable_references_code_lens = true,
    },
    ["csharp|completion"] = {
      dotnet_show_completion_items_from_unimported_namespaces = true,
      dotnet_show_name_completion_suggestions = true,
    },
  },
})

return {
  {
    "GustavEikaas/easy-dotnet.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "folke/snacks.nvim" },
    config = function()
      local dotnet = require("easy-dotnet")

      dotnet.setup({
        picker = "snacks",
        ---@type TestRunnerOptions
        test_runner = {
          viewmode = "float",
          mapping = {
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
  {
    "folke/snacks.nvim",
    ---@type snacks.Config
    opts = {
      picker = {
        sources = {
          explorer = {
            win = {
              list = {
                keys = {
                  ["A"] = "explorer_add_dotnet",
                },
              },
            },
            actions = {
              explorer_add_dotnet = function(picker)
                local dir = picker:dir()
                require("easy-dotnet").create_new_item(dir)
              end,
            },
          },
        },
      },
    },
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
        "roslyn",
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
    enabled = false,
  },
  {
    "nvim-neotest/neotest",
    enabled = false,
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
