return {
  "pwntester/octo.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "ibhagwan/fzf-lua",
    "nvim-tree/nvim-web-devicons",
  },
  cmd = { "Octo" },
  keys = {
    { "<leader>pd", "<cmd>Octo review browse<cr>", desc = "Browse PR diff (GitHub API)" },
    { "<leader>ps", "<cmd>Octo review start<cr>", desc = "Start PR review" },
    { "<leader>pm", "<cmd>Octo review submit<cr>", desc = "Submit PR review" },
  },
  config = function()
    require("octo").setup({
      picker = "fzf-lua",
      reviews = {
        auto_show_threads = true,
      },
    })
  end,
}
