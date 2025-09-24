return {
  "ibhagwan/fzf-lua",
  event = "VeryLazy",
  keys = {
    { "<C-p>", "<cmd>FzfLua files<cr>", desc = "Find files" },
    { "<C-f>", "<cmd>FzfLua live_grep<cr>", desc = "Live grep" },
    { "<leader>b", "<cmd>FzfLua buffers<cr>", desc = "Find buffers" },
    {
      "<leader>;",
      function()
        require("fzf-lua").buffers({
          sort_mru = true,
          sort_lastused = true,
          ignore_current_buffer = true,
        })
      end,
      desc = "Find in buffers",
    },
    { "<leader>o", "<cmd>FzfLua oldfiles<cr>", desc = "Recent files" },
  },
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("fzf-lua").setup({
      "telescope",
      fzf_bin = "fzf",
      fzf_opts = {
        ["--no-multi"] = "",
        ["--bind"] = "enter:accept",
      },
    })
  end,
}