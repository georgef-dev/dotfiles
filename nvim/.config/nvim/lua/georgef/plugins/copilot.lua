return {
  "github/copilot.vim",
  lazy = false,
  config = function()
    vim.g.copilot_no_tab_map = true
    vim.g.copilot_enabled = true

    vim.g.copilot_filetypes = {
      ["*"] = true,
      ["markdown"] = false,
      ["text"] = false,
    }

    -- Custom key mappings for Copilot
    vim.api.nvim_set_keymap("i", "<C-j>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
  end,
}

