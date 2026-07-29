-- In-buffer markdown rendering (headings, tables, checkboxes, code blocks).
-- Toggle with :RenderMarkdown toggle
return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.icons" },
    opts = {
      heading = { border = true },
      code = { width = "block", min_width = 45 },
    },
  },
}
