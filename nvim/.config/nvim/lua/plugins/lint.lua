return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        lua = {
          cmd = "luacheck",
          stdin = true,
          args = { "--formatter", "plain", "--codes", "--ranges", "-", "--globlals", "vim" },
          ignore_exitcode = true,
          parser = require("lint.parser").from_pattern(
            pattern,
            groups,
            severities,
            { ["source"] = "luacheck" },
            { end_col_offset = 0 }
          ),
        },
      },
    },
  },
}
