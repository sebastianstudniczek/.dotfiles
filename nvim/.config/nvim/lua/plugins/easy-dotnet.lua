-- TODO: Implement in easy dotnet
-- Fix usings
vim.api.nvim_create_user_command("CSFixUsings", function()
  local bufnr = vim.api.nvim_get_current_buf()

  local clients = vim.lsp.get_clients({ name = "easy_dotnet" })
  if not clients or vim.tbl_isempty(clients) then
    vim.notify("Couldn't find client", vim.log.levels.ERROR, { title = "Roslyn" })
    return
  end

  local client = clients[1]
  local action = {
    kind = "quickfix",
    data = {
      CustomTags = { "RemoveUnnecessaryImports" },
      TextDocument = { uri = vim.uri_from_bufnr(bufnr) },
      CodeActionPath = { "Remove unnecessary usings" },
      Range = {
        ["start"] = { line = 0, character = 0 },
        ["end"] = { line = 0, character = 0 },
      },
      UniqueIdentifier = "Remove unnecessary usings",
    },
  }

  client:request("codeAction/resolve", action, function(err, resolved_action)
    if err then
      vim.notify(err)
      vim.notify("Fix using directives failed", vim.log.levels.ERROR, { title = "Roslyn" })
      return
    end
    vim.lsp.util.apply_workspace_edit(resolved_action.edit, client.offset_encoding)
  end)
end, { desc = "Remove unnecessary using directives" })

-- -@diagnostic disable: missing-fields
return {
  {
    "GustavEikaas/easy-dotnet.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "folke/snacks.nvim" },
    config = function()
      local dotnet = require("easy-dotnet")

      ---@type easy-dotnet.Options
      local cfg = {
        lsp = {
          easy_dotnet_extension_enabled = true,
          enhanced_rename = true,
          create_type_from_usage = true,
          restart_roslyn_on_branch_change = true,
          razor = {
            enabled = false,
          },
        },
        --INFO: Snacks is somehow ignoring shellslash option and passing forward slash path
        --while using it as picker to choose dll to debug
        picker = "snacks",
        auto_bootstrap_namespace = {
          type = "file_scoped",
        },
        test_runner = {
          neotest_integration = true,
          viewmode = "vsplit",
          vsplit_width = 70,
          auto_start_testrunner = true,
        },
        debugger = {
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

      if not vim.g.neotest_enabled then
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
