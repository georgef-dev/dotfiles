return {
  "rose-pine/neovim",
  lazy = false,
  priority = 1000,
  name = "rose-pine",
  config = function()
    require("rose-pine").setup {
      variant = "auto",
      dark_variant = "main",
    }
    vim.cmd.colorscheme "rose-pine"
  end,
}
