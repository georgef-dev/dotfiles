-- vim-test strategy that runs tests in a dedicated Herdr pane.
-- Pane id is process-local only; never search/reuse arbitrary panes.

local test_pane_id ---@type string|nil

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "herdr-test" })
end

local function herdr_bin()
  local path = vim.env.HERDR_BIN_PATH
  if type(path) == "string" and path ~= "" and vim.fn.executable(path) == 1 then
    return path
  end
  return "herdr"
end

---Run herdr with an argv list (no shell concatenation).
---@param args string[]
---@return vim.SystemCompleted
local function herdr(args)
  local cmd = { herdr_bin() }
  vim.list_extend(cmd, args)
  return vim.system(cmd, { text = true }):wait()
end

---@param completed vim.SystemCompleted
---@return table|nil
local function decode_json(completed)
  if not completed.stdout or completed.stdout == "" then
    return nil
  end
  local ok, data = pcall(vim.json.decode, completed.stdout)
  if not ok then
    return nil
  end
  return data
end

---@param pane_id string
---@return boolean
local function pane_exists(pane_id)
  local res = herdr({ "pane", "get", pane_id })
  if res.code ~= 0 then
    return false
  end
  local data = decode_json(res)
  local id = data and data.result and data.result.pane and data.result.pane.pane_id
  return type(id) == "string" and id ~= ""
end

---@return string|nil pane_id
local function create_test_pane()
  local nvim_pane = vim.env.HERDR_PANE_ID
  if type(nvim_pane) ~= "string" or nvim_pane == "" then
    notify("HERDR_PANE_ID is required (run Neovim inside a Herdr pane)", vim.log.levels.ERROR)
    return nil
  end

  local cwd = vim.fn.getcwd()
  local res = herdr({
    "pane",
    "split",
    nvim_pane,
    "--direction",
    "down",
    "--ratio",
    "0.7",
    "--cwd",
    cwd,
    "--no-focus",
  })

  if res.code ~= 0 then
    local err = (res.stderr and res.stderr ~= "" and res.stderr) or res.stdout or "unknown error"
    notify("Failed to split Herdr test pane: " .. vim.trim(err), vim.log.levels.ERROR)
    return nil
  end

  local data = decode_json(res)
  local pane_id = data and data.result and data.result.pane and data.result.pane.pane_id
  if type(pane_id) ~= "string" or pane_id == "" then
    notify("Herdr split response missing .result.pane.pane_id", vim.log.levels.ERROR)
    return nil
  end

  return pane_id
end

---@param pane_id string
local function wait_for_pane_ready(pane_id)
  local ready = vim.wait(8000, function()
    local res = herdr({ "pane", "get", pane_id })
    if res.code ~= 0 then
      return false
    end
    local data = decode_json(res)
    local pane = data and data.result and data.result.pane
    return pane and ((pane.revision or 0) > 0 or (pane.terminal_title or "") ~= "")
  end, 100)

  if not ready then
    notify("Herdr test pane shell was slow to initialize; running anyway", vim.log.levels.WARN)
  end
end

---@return string|nil pane_id
---@return boolean reused true when an existing stored pane will be reused
local function ensure_test_pane()
  if test_pane_id then
    if pane_exists(test_pane_id) then
      return test_pane_id, true
    end
    -- Missing pane: forget and recreate. Never search for a replacement.
    test_pane_id = nil
    notify("Stored Herdr test pane is gone; creating a new one", vim.log.levels.WARN)
  end

  local pane_id = create_test_pane()
  if not pane_id then
    return nil, false
  end
  test_pane_id = pane_id
  wait_for_pane_ready(test_pane_id)
  return test_pane_id, false
end

---@param cmd string
local function run_in_test_pane(cmd)
  local pane_id, reused = ensure_test_pane()
  if not pane_id then
    return
  end

  -- Later runs only: interrupt the previous command in the stored pane.
  if reused then
    herdr({ "pane", "send-keys", pane_id, "ctrl+c" })
  end

  local res = herdr({ "pane", "run", pane_id, cmd })
  if res.code ~= 0 then
    local err = (res.stderr and res.stderr ~= "" and res.stderr) or res.stdout or "unknown error"
    notify("Failed to run tests in Herdr pane: " .. vim.trim(err), vim.log.levels.ERROR)
  end
end

-- Lua entrypoint called from the Vimscript strategy wrapper.
function _G.HerdrTestStrategy(cmd)
  if type(cmd) ~= "string" or cmd == "" then
    notify("Empty test command", vim.log.levels.ERROR)
    return
  end
  run_in_test_pane(cmd)
end

return {
  "vim-test/vim-test",
  config = function()
    -- vim-test calls g:test#custom_strategies['herdr'](cmd), which needs a real
    -- Vimscript Funcref. Assigning the dict through vim.g from Lua downgrades the
    -- value to a string and fails with "Funcref needed", so build the entry in
    -- Vimscript where function(...) yields a genuine Funcref.
    vim.cmd([[
      function! HerdrTestStrategy(cmd) abort
        call v:lua.HerdrTestStrategy(a:cmd)
      endfunction
      let g:test#custom_strategies = get(g:, 'test#custom_strategies', {})
      let g:test#custom_strategies['herdr'] = function('HerdrTestStrategy')
    ]])

    vim.g["test#strategy"] = "herdr"

    vim.api.nvim_create_user_command("HerdrTestPaneReset", function()
      test_pane_id = nil
      notify("Forgot Herdr test pane id (pane left open)")
    end, {
      desc = "Forget the stored Herdr vim-test pane id without closing the pane",
    })
  end,
  keys = {
    {
      "<leader>tf",
      ":TestFile<cr>",
      desc = "Test current file",
    },
    {
      "<leader>tn",
      ":TestNearest<cr>",
      desc = "Test nearest",
    },
    {
      "<leader>tt",
      ":TestLast<cr>",
      desc = "Rerun last test",
    },
  },
}
