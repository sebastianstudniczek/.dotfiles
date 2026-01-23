return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      codelens = {
        enabled = true,
      },
      inlay_hints = { enabled = false },
      servers = {
        ["*"] = {
          keys = {
            { "<leader>ca", false },
            -- HACK: Needed to remap key in terminal or os since by default terminals can't recognize such sequence
            { "<C-.>", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "x" }, has = "codeAction" },
          },
        },
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
