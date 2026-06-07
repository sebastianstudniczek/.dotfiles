local kind = require("blink.cmp.types").CompletionItemKind

return {
  -- Use mini icons in completions
  {
    "saghen/blink.cmp",
    opts = {
      fuzzy = {
        implementation = "prefer_rust_with_warning",
      },
      keymap = {
        preset = "enter",

        -- Accept completion like Rider
        ["<CR>"] = {
          function(cmp)
            if not cmp.is_visible() then
              return
            end
            if cmp.accept() then
              -- Insert space after a keyword
              if cmp.get_selected_item().kind == kind.Keyword then
                vim.schedule(function()
                  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Space>", true, false, true), "n", false)
                end)
              end
              return true
            end

            return false
          end,
          "fallback",
        },
      },
      completion = {
        menu = {
          draw = {
            components = {
              kind_icon = {
                text = function(ctx)
                  local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
                  return kind_icon
                end,
                -- (optional) use highlights from mini.icons
                highlight = function(ctx)
                  local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                  return hl
                end,
              },
              kind = {
                -- (optional) use highlights from mini.icons
                highlight = function(ctx)
                  local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                  return hl
                end,
              },
            },
          },
          border = "rounded",
          winhighlight = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,CursorLine:BlinkCmpDocCursorLine,Search:None",
        },
        documentation = {
          window = {
            border = "rounded",
          },
        },
      },
    },
  },
}
