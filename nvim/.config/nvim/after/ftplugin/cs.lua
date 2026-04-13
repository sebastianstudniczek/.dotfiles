vim.keymap.set("n", "<leader>coi", ":CSFixUsings<CR>", {
  desc = "Remove unnecessary using directives",
}, { buffer = true })

if _G.MiniKeymap then
  -- Act only when cursor is between `{}`
  local is_inside_braces = function()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    return line:sub(col, col + 1) == "{}"
  end
  -- Mock a sequence of keys that produce an Allman style
  -- NOTE: It is not perfect, as there might be issues with indentation and
  -- trailing whitespace. Adjust it to fit the use case better
  local allman_action = function()
    return "<Left><CR><Right><CR><CR><Up><Tab>"
  end
  local allman_step = { condition = is_inside_braces, action = allman_action }

  -- Create a buffer-local mapping that doesn't remap (to be able to use `<CR>` in the output
  -- without infinite recursion
  local opts = { remap = false, buf = 0 }
  MiniKeymap.map_multistep("i", "<CR>", { "pmenu_accept", allman_step, "minipairs_cr" }, opts)
end
