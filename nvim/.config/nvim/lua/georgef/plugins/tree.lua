return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  keys = {
    {
      "<C-n>",
      "<cmd> Neotree toggle <CR>",
      desc = "Toggle neotree",
    },
    {
      "<leader>s",
      "<cmd> Neotree float git_status <CR>",
      desc = "Neotree git_status",
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
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
