return {
  "vim-test/vim-test",
  keys = {
    {
      "<leader>tf",
      ":TestFile -strategy=neovim<cr>",
      desc = "Test current file",
    },
    {
      "<leader>tn",
      ":TestNearest -strategy=neovim<cr>",
      desc = "Test nearest in  file",
    },
    {
      "<leader>tt",
      ":TestLast -strategy=neovim<cr>",
      desc = "Rerun last test",
    },
  },
}
