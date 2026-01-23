return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      --INFO: If enabled messes with blink cmp doc popup, causing it to not redner it properly
      --https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/577
      patterns = { markdown = { disable = false } },
    },
  },
}
