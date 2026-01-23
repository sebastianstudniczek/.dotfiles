local handle = nil
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
}
