return {
  {
    'rose-pine/neovim',
    enabled = true,
    name = 'rose-pine',
    config = function()
      require('rose-pine').setup {
        styles = {
          transparency = true,
          italic = false,
        },
        highlight_groups = {
          NormalFloat = { bg = 'NONE' },
          BlinkCmpDoc = { bg = 'NONE' },
          BlinkCmpLabel = { fg = 'foam' },
          -- ["@variable"] = { fg = "text" },
          -- ["@variable.c_sharp"] = { link = "@variable" },
          -- ["@variable.member.c_sharp"] = { linkt = "@variable" },
          -- ["@variable.parameter"] = { link = "@variable" },
          -- ["@variable.parameter.c_sharp"] = { link = "@variable" },
        },
      }
      vim.cmd 'colorscheme rose-pine-moon'
    end,
  },
  {
    'mbwilding/gronk.nvim',
    enabled = false,
    lazy = false,
    priority = 1000,
    config = function()
      -- Optional setup
      require('gronk').setup {
        transparent = true,
      }

      -- Sets theme
      vim.cmd [[colorscheme gronk]]
    end,
  },
  -- { -- You can easily change to a different colorscheme.
  --   -- Change the name of the colorscheme plugin below, and then
  --   -- change the command in the config to whatever the name of that colorscheme is.
  --   --
  --   -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
  --   'folke/tokyonight.nvim',
  --   priority = 1000, -- Make sure to load this before all the other start plugins.
  --   enabled = false,
  --   config = function()
  --     ---@diagnostic disable-next-line: missing-fields
  --     require('tokyonight').setup {
  --       transparent = true,
  --       styles = {
  --         sidebars = 'transparent',
  --         floats = 'transparent',
  --         comments = { italic = false }, -- Disable italics in comments
  --       },
  --     }
  --
  --     -- Load the colorscheme here.
  --     -- Like many other themes, this one has different styles, and you could load
  --     -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
  --     vim.cmd.colorscheme 'tokyonight-night'
  --   end,
  -- },
}
