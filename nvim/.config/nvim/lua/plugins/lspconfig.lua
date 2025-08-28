return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      codelens = {
        enabled = true,
      },
      inlay_hints = { enabled = false },
      servers = {
        bashls = {
          filetypes = { "sh", "zsh" },
        },
        lua_ls = {
          settings = {
            Lua = {
              workspace = {
                -- Make neovim aware of runtime files
                library = vim.api.nvim_get_runtime_file("", true),
              },
              diagnostics = {
                -- globals = { "vim" },
              },
            },
          },
        },
      },
    },
  },
}
