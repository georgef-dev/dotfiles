return {
  {
    "tpope/vim-fugitive",
    lazy = false,
    keys = {
      { "<leader>gb", "<cmd>Git blame<cr>", desc = "Git blame (full file)" },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    lazy = false,
    config = function()
      require("gitsigns").setup()

      vim.keymap.set("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", {})
      vim.keymap.set(
        "n",
        "<leader>gt",
        ":Gitsigns toggle_current_line_blame<CR>",
        {}
      )
    end,
  },
  {
    "sindrets/diffview.nvim",
    commit = "5532482a5aef52021347e16f13e1ee73b8c7b436",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Open diff view" },
      {
        "<leader>gc",
        function()
          -- Close diffview if open, otherwise close current tab (octo review)
          local lib = require("diffview.lib")
          local view = lib.get_current_view()
          if view then
            vim.cmd("DiffviewClose")
          else
            pcall(vim.cmd, "tabclose")
          end
        end,
        desc = "Close diff/review",
      },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
      {
        "<leader>pr",
        "<cmd>DiffviewOpen origin/main...HEAD<cr>",
        desc = "Review PR changes",
      },
    },
    config = function()
      require("diffview").setup({
        file_panel = {
          listing_style = "list",
          tree_options = {
            flatten_dirs = false,
          },
        },
      })
    end,
  },
}
