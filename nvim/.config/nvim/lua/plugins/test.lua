return {
  "vim-test/vim-test",
  config = function()
    vim.g["test#strategy"] = "neovim"
  end,
  keys = {
    {
      "<leader>tf",
      ":TestFile<cr>",
      desc = "Test current file",
    },
    {
      "<leader>tn",
      ":TestNearest<cr>",
      desc = "Test nearest",
    },
    {
      "<leader>tt",
      ":TestLast<cr>",
      desc = "Rerun last test",
    },
  },
}
