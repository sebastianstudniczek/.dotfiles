return {
  {
    "rcarriga/nvim-dap-ui",
    enabled = false,
    opts = {
      expand_lines = true,
      controls = { enabled = false },
      floating = { border = "rounded" },

      layouts = {
        {
          elements = {
            { id = "scopes", size = 0.5 },
            { id = "repl", size = 0.5 },
          },
          size = 15,
          position = "bottom",
        },
      },
    },
  },
  {
    "igorlfs/nvim-dap-view",
    lazy = false,
    version = "1.*",
    opts = {
      auto_toggle = true,
      virtual_text = {
        -- Use nvim-dap-virtual-text plugin for now since this one lacks some features
        -- evaluate later
        enabled = false,
      },
    },
  },
}
