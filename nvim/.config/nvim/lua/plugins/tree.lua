return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  keys = {
    {
      "<C-n>",
      "<cmd>Neotree filesystem toggle reveal=true reveal_force_cwd<CR>",
      desc = "Toggle neotree with current file focused",
    },
    {
      "<leader>s",
      "<cmd>Neotree float git_status<CR>",
      desc = "Neotree git_status",
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    require("neo-tree").setup {
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
        },
        follow_current_file = {
          enabled = true,
        },
        use_libuv_file_watcher = true,
      },
      buffers = {
        follow_current_file = {
          enabled = true,
        },
      },
    }
  end,
}

--return {
--  "nvim-tree/nvim-tree.lua",
--  cmd = { "NvimTreeToggle", "NvimTreeFocus" },
--  keys = {
--    { "<C-n>", "<cmd> NvimTreeToggle <CR>", desc = "Toggle nvimtree" },
--  },
--  dependencies = { "nvim-tree/nvim-web-devicons" },
--  config = function()
--    require("nvim-tree").setup {
--      view = {
--        width = 100,
--      },
--      renderer = {
--        icons = {
--          git_placement = "after",
--        },
--      },
--    }
--  end,
--}
