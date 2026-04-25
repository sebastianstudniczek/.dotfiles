local handle = nil

-- Add syntax highlighting for neotest output using log-highlight.nvim
vim.api.nvim_create_autocmd("FileType", {
  pattern = "neotest-output",
  callback = function()
    -- relies on log-highlight.nvim being installed
    -- This tells Neovim to use the syntax rules defined for .log files
    -- while keeping the 'neotest-output' filetype for functionality.
    vim.bo.syntax = "log"

    -- HACK: Looks like neotest is setting options after buffer is created
    vim.defer_fn(function()
      if vim.api.nvim_buf_is_valid(0) then
        vim.bo.syntax = "log"
      end
    end, 10)
  end,
})

return {
  {
    "nvim-neotest/neotest",
    opts = {
      consumers = {
        discovery_handler = function(client)
          client.listeners.starting = function()
            handle = require("fidget.progress").handle.create({
              title = "Finding tests",
              message = "In progress...",
              lsp_client = {
                name = "Neotest",
              },
            })
          end
          return {}
        end,
        discovery_results = function(client)
          client.listeners.started = function()
            if handle then
              handle.message = "Completed"
              handle:finish()
            end
          end
          return {}
        end,
      },
      adapters = {
        ["neotest-vstest"] = {},
        icons = {
          running_animated = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
        },
        floating = {
          border = "rounded",
        },
      },
    },
  },
}
