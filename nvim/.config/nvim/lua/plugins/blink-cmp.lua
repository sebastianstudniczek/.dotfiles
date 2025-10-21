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
    opts = {
      fuzzy = {
        sorts = {
          "exact",
          "score",
          -- Simulate sorting order similar like in Rider
          -- TODO: Waiting for this to be implemented https://github.com/saghen/blink.cmp/issues/2073
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
