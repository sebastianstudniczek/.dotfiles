return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      codelens = {
        enabled = true,
      },
      -- LSP Server Settings
      ---@type lspconfig.options
      servers = {
        bashls = {
          filetypes = { "sh", "zsh" },
        },
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                -- TODO: Kinda hack, not really solving the issue but ignores it. But currently reading VIMRUNTIME does not work properyly
                globals = { "vim" },
              },
            },
          },
        },
      },
    },
  },
}
