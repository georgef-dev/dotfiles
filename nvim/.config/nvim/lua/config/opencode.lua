local M = {}

function M.find_opencode_panes()
  local panes = {}
  local result = vim.fn.system('tmux list-panes -a -F "#{pane_id} #{session_name}:#{window_name} #{pane_current_command}"')
  for line in result:gmatch("[^\n]+") do
    if line:match("opencode") then
      local pane_id, label = line:match("^(%%[%d]+)%s+(.+)%s+%S+$")
      if pane_id then
        table.insert(panes, { id = pane_id, label = label })
      end
    end
  end
  return panes
end

function M.get_visual_selection()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local mode = vim.fn.visualmode()
  if mode == "" then
    mode = "v"
  end
  local lines = vim.fn.getregion(start_pos, end_pos, { type = mode })
  return lines
end

local function send_to_pane(pane_id, message)
  local tmpfile = vim.fn.tempname()
  local f = assert(io.open(tmpfile, "w"))
  f:write(message)
  f:close()

  vim.fn.system(string.format("tmux load-buffer %s", vim.fn.shellescape(tmpfile)))
  vim.fn.system(string.format("tmux paste-buffer -p -t %s", vim.fn.shellescape(pane_id)))
  vim.fn.system(string.format("tmux send-keys -t %s Enter", vim.fn.shellescape(pane_id)))

  os.remove(tmpfile)
end

local function with_pane(callback)
  local panes = M.find_opencode_panes()
  if #panes == 0 then
    vim.notify("No OpenCode pane found", vim.log.levels.ERROR)
    return
  end

  if #panes == 1 then
    callback(panes[1].id)
  else
    vim.ui.select(panes, {
      prompt = "Select OpenCode pane:",
      format_item = function(pane)
        return pane.label
      end,
    }, function(choice)
      if not choice then
        return
      end
      callback(choice.id)
    end)
  end
end

function M.send_to_opencode()
  local lines = M.get_visual_selection()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
  if not lines or #lines == 0 then
    vim.notify("No selection", vim.log.levels.WARN)
    return
  end

  local filetype = vim.bo.filetype or ""

  with_pane(function(pane_id)
    vim.ui.input({ prompt = "OpenCode prompt: " }, function(prompt)
      if not prompt or prompt == "" then
        return
      end
      local code = table.concat(lines, "\n")
      local filepath = vim.fn.expand("%:.")
      local message = prompt .. "\n\n`" .. filepath .. "`:\n```" .. filetype .. "\n" .. code .. "\n```\n"
      send_to_pane(pane_id, message)
    end)
  end)
end

function M.prompt_opencode()
  with_pane(function(pane_id)
    vim.ui.input({ prompt = "OpenCode prompt: " }, function(prompt)
      if not prompt or prompt == "" then
        return
      end
      send_to_pane(pane_id, prompt .. "\n")
    end)
  end)
end

vim.keymap.set("v", "<leader>oc", ":<C-u>lua require('config.opencode').send_to_opencode()<CR>", { desc = "Send to [o]pen[c]ode" })
vim.keymap.set("n", "<leader>oc", M.prompt_opencode, { desc = "Prompt [o]pen[c]ode" })

return M
