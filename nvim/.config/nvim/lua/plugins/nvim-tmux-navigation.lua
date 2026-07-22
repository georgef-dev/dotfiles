return {
  "alexghergh/nvim-tmux-navigation",
  lazy = false,
  config = function()
    require("nvim-tmux-navigation").setup({})

    local function navigate(wincmd, direction, tmux_command)
      local previous_window = vim.api.nvim_get_current_win()
      vim.cmd("wincmd " .. wincmd)

      if vim.api.nvim_get_current_win() ~= previous_window then
        return
      end

      if vim.env.HERDR_PANE_ID and vim.env.HERDR_PANE_ID ~= "" then
        local herdr = vim.env.HERDR_BIN_PATH
        if not herdr or herdr == "" then
          herdr = "herdr"
        end
        vim.fn.system({ herdr, "pane", "focus", "--direction", direction, "--current" })
      elseif vim.env.TMUX and vim.env.TMUX ~= "" then
        vim.cmd(tmux_command)
      end
    end

    vim.keymap.set("n", "<C-h>", function()
      navigate("h", "left", "NvimTmuxNavigateLeft")
    end, { silent = true, desc = "Navigate left (Nvim/Herdr/tmux)" })
    vim.keymap.set("n", "<C-j>", function()
      navigate("j", "down", "NvimTmuxNavigateDown")
    end, { silent = true, desc = "Navigate down (Nvim/Herdr/tmux)" })
    vim.keymap.set("n", "<C-k>", function()
      navigate("k", "up", "NvimTmuxNavigateUp")
    end, { silent = true, desc = "Navigate up (Nvim/Herdr/tmux)" })
    vim.keymap.set("n", "<C-l>", function()
      navigate("l", "right", "NvimTmuxNavigateRight")
    end, { silent = true, desc = "Navigate right (Nvim/Herdr/tmux)" })
  end,
}
