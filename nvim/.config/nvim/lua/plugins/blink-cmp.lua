local kind = require("blink.cmp.types").CompletionItemKind

local order = {
  [kind.Field] = 1,
  [kind.Property] = 2,
  [kind.Method] = 3,
  [kind.Operator] = 4,
}

return {
  -- Use mini icons in completions
  {
    "saghen/blink.cmp",
    ---@type blink.cmp.Config
    opts = {
      fuzzy = {
        implementation = "prefer_rust_with_warning",

        sorts = function()
          if vim.bo.filetype ~= "cs" then
            return {
              "exact",
              "score",
              "sort_text",
              "kind",
              "label",
            }
          end

          return {
            "exact",
            "score",
            function(a, b)
              if a.client_name ~= "roslyn" and b.client_name ~= "roslyn" then
                return
              end

              local a_order = order[a.kind]
              local b_order = order[b.kind]

              if a_order == nil and b_order == nil then
                return
              end

              if a_order == nil and b_order ~= nil then
                return false
              end

              if a_order ~= nil and b_order == nil then
                return true
              end

              return a_order < b_order
            end,

            "sort_text",
            "kind",
            "label",
          }
        end,
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
        accept = {
          auto_brackets = {
            -- Currently there is an issue with adding unnecessary paranthesis
            semantic_token_resolution = {
              enabled = false,
            },
          },
        },
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
