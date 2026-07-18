return {
  {
    "folke/zen-mode.nvim",
    name = "zen-mode",
    config = function()
      require("zen-mode").setup({
        plugins = {
          options = {
            enabled = true,
            ruler = true,
            showcmd = true,
            laststatus = 3,
          },
        },
      })
    end,
  },
}
