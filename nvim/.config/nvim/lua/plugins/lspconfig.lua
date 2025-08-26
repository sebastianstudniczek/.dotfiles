return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      codelens = {
        enabled = true,
      },
      inlay_hints = { enable = false },
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
