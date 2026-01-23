return {
  {
    "tpope/vim-fugitive",
    lazy = false,
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
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Open diff view" },
      { "<leader>gc", "<cmd>DiffviewClose<cr>", desc = "Close diff view" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
      {
        "<leader>pr",
        function()
          local handle = io.popen("gt parent 2>/dev/null")
          if handle then
            local parent = handle:read("*a"):gsub("%s+", "")
            handle:close()
            if parent ~= "" then
              vim.cmd("DiffviewOpen " .. parent .. "...HEAD")
            else
              vim.notify("No parent branch found (not tracked by Graphite?)", vim.log.levels.WARN)
            end
          end
        end,
        desc = "Review PR changes",
      },
    },
    config = function()
      require("diffview").setup()
    end,
  },
}
