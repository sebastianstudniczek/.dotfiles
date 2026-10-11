return {
  "folke/sidekick.nvim",
  cli = {
    mux = {
      backend = "tmux",
      enabled = true,
    },
  },
  opts = {
    nes = {
      enabled = false
    },
    copilot = {
      status = {
        enabled = false
      },
    },
  },
  keys = {
    {
      "<leader>ao",
      function()
        require("sidekick.cli").toggle({ name = "opencode", focus = true })
      end,
      desc = "Sidekick OpenCode",
    },
    {
      "<leader>ao",
      function()
        require("sidekick.cli").toggle({ name = "claude", focus = true })
      end,
      desc = "Sidekick Claude Code",
    },
  },
}
