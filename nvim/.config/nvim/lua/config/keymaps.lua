vim.keymap.set("n", ";", ":")
vim.keymap.set("n", "<C-H>", "<C-W><C-H>")
vim.keymap.set("n", "<C-J>", "<C-W><C-J>")
vim.keymap.set("n", "<C-K>", "<C-W><C-K>")
vim.keymap.set("n", "<C-L>", "<C-W><C-L>")
vim.keymap.set("n", "<C-S>", ":%s/")
vim.keymap.set("n", "sp", ":sp<CR>")
vim.keymap.set("n", "vs", ":vs<CR>")
vim.keymap.set("n", "<leader>j", ":cnext<CR>", { silent = true })
vim.keymap.set("n", "<leader>k", ":cprevious<CR>", { silent = true })
vim.keymap.set("n", "<leader>f", function()
  require("conform").format({ async = false, timeout_ms = 10000 })
end, { desc = "Format buffer" })
vim.keymap.set("n", "<A-j>", ":m+1<CR>==")
vim.keymap.set("n", "<A-k>", ":m-2<CR>==")
vim.keymap.set(
  "n",
  "<leader>x",
  ":bp<bar>sp<bar>bn<bar>bd<CR>",
  { silent = true }
)

vim.keymap.set("v", "<C-J>", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "<C-K>", ":m '<-2<CR>gv=gv")

-- Case conversion helpers
local function to_snake_case(str)
  return str:gsub("(%u)", function(c)
    return "_" .. c:lower()
  end):gsub("^_", "")
end

local function to_camel_case(str)
  return str:gsub("_(%l)", function(c)
    return c:upper()
  end)
end

local function is_snake_case(str)
  return str:match("_") ~= nil
end

vim.keymap.set("n", "<leader>cc", function()
  local word = vim.fn.expand("<cword>")
  local new_word
  if is_snake_case(word) then
    new_word = to_camel_case(word)
  else
    new_word = to_snake_case(word)
  end
  vim.cmd("normal! ciw" .. new_word)
end, { desc = "[c]onvert [c]ase (snake <-> camel)" })

-- RBS signature expansion
vim.keymap.set("n", "<leader>rs", function()
  local line_num = vim.fn.line(".")
  local line = vim.fn.getline(line_num)

  -- Extract indentation
  local indent = line:match("^(%s*)#:")
  if not indent then
    print("Not on an RBS signature line")
    return
  end

  local rbs_cont = indent .. "#|   "
  local rbs_close = indent .. "#| "

  -- Find the parameter section (between ( and ) ->)
  local prefix, params, suffix = line:match("^(.-)%((.-)%)%s*%->%s*(.*)$")
  if not params then
    print("Could not parse signature")
    return
  end

  -- Split params by comma, but only at depth 0 (not inside [], {}, or <>)
  local result = {}
  local current = ""
  local depth = 0

  for i = 1, #params do
    local char = params:sub(i, i)

    if char == "[" or char == "{" or char == "<" then
      depth = depth + 1
      current = current .. char
    elseif char == "]" or char == "}" or char == ">" then
      depth = depth - 1
      current = current .. char
    elseif char == "," and depth == 0 then
      table.insert(result, vim.trim(current))
      current = ""
    else
      current = current .. char
    end
  end

  -- Add the last parameter
  if #vim.trim(current) > 0 then
    table.insert(result, vim.trim(current))
  end

  -- Build the new signature
  local new_lines = { prefix .. "(" }
  for _, param in ipairs(result) do
    table.insert(new_lines, rbs_cont .. param .. ",")
  end
  -- Remove trailing comma from last param
  new_lines[#new_lines] = new_lines[#new_lines]:sub(1, -2)
  table.insert(new_lines, rbs_close .. ") -> " .. suffix)

  -- Replace the line
  vim.api.nvim_buf_set_lines(0, line_num - 1, line_num, false, new_lines)
end, { desc = "[r]efactor [s]ignature" })

-- Method head expansion
vim.keymap.set("n", "<leader>rh", function()
  local line_num = vim.fn.line(".")
  local line = vim.fn.getline(line_num)

  local indent = line:match("^(%s*)def")
  if not indent then
    print("Not on a method definition line")
    return
  end

  local param_indent = indent .. "  "

  vim.cmd(line_num .. "s/,\\s*/,/g")
  vim.cmd(line_num .. "s/(\\|,/&\\r" .. param_indent .. "/g")
  vim.cmd("'[,']s/)$/\\r" .. indent .. ")/")
end, { desc = "[r]efactor method [h]ead" })
