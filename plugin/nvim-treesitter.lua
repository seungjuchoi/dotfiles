-- nvim-treesitter setup (main branch, Neovim 0.12+)
require('nvim-treesitter').setup {
  install_dir = vim.fn.stdpath('data') .. '/site',
}

-- Install parsers (async, no-op if already installed)
require('nvim-treesitter').install {
  'fish', 'html', 'yaml', 'markdown', 'markdown_inline',
  'c', 'cpp', 'go', 'lua', 'python', 'rust', 'typescript', 'vim', 'json',
  'gitignore', 'dockerfile',
}

-- Highlighting: enable treesitter highlight for all supported filetypes
vim.api.nvim_create_autocmd('FileType', {
  callback = function()
    pcall(vim.treesitter.start)
  end,
})

-- Indentation (experimental)
vim.api.nvim_create_autocmd('FileType', {
  callback = function()
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})

-- Incremental selection (treesitter node-based, stack-based like original)
do
  ---@type table<integer, TSNode[]>
  local selections = {}

  --- Get the current visual selection range (1-indexed, end-inclusive, like vim)
  local function visual_selection_range()
    local _, csrow, cscol, _ = unpack(vim.fn.getpos('v'))
    local _, cerow, cecol, _ = unpack(vim.fn.getpos('.'))
    if csrow < cerow or (csrow == cerow and cscol <= cecol) then
      return csrow, cscol, cerow, cecol
    else
      return cerow, cecol, csrow, cscol
    end
  end

  --- Convert 0-indexed ts range to 1-indexed vim range
  local function get_vim_range(node)
    local sr, sc, er, ec = node:range()
    -- end_col is exclusive in treesitter, make it inclusive for vim
    -- if ec == 0 then the node ends at the last col of previous row
    if ec == 0 then
      er = er - 1
      ec = #vim.fn.getline(er + 1)
    end
    return sr + 1, sc + 1, er + 1, ec
  end

  --- Select a node visually
  local function update_selection(node)
    local sr, sc, er, ec = get_vim_range(node)
    local mode = vim.api.nvim_get_mode().mode
    if mode ~= 'v' then
      vim.cmd('normal! v')
    end
    vim.api.nvim_win_set_cursor(0, { sr, sc - 1 })
    vim.cmd('normal! o')
    vim.api.nvim_win_set_cursor(0, { er, ec - 1 })
  end

  --- Check if node range matches current visual selection
  local function range_matches(node)
    local csrow, cscol, cerow, cecol = visual_selection_range()
    local srow, scol, erow, ecol = get_vim_range(node)
    return srow == csrow and scol == cscol and erow == cerow and ecol == cecol
  end

  --- Generic incremental select: walk up using get_parent until range changes
  local function select_incremental(get_parent)
    return function()
      local buf = vim.api.nvim_get_current_buf()
      local nodes = selections[buf]

      local csrow, cscol, cerow, cecol = visual_selection_range()

      -- If no history or visual range diverged from last stored node, re-init
      if not nodes or #nodes == 0 or not range_matches(nodes[#nodes]) then
        local parser = vim.treesitter.get_parser(buf)
        parser:parse()
        local node = parser:named_node_for_range(
          { csrow - 1, cscol - 1, cerow - 1, cecol },
          { ignore_injections = false }
        )
        if not node then return end
        update_selection(node)
        if nodes and #nodes > 0 then
          table.insert(selections[buf], node)
        else
          selections[buf] = { node }
        end
        return
      end

      -- Walk up from last stored node until range actually changes
      local node = nodes[#nodes]
      while true do
        local parent = get_parent(node)
        if not parent or parent == node then
          -- Try crossing injection boundary to parent parser
          local parser = vim.treesitter.get_parser(buf)
          parser:parse()
          local ok, current_lang = pcall(parser.language_for_range, parser,
            { csrow - 1, cscol - 1, cerow - 1, cecol })
          if not ok or current_lang == parser then
            -- Already at root
            local root_node = parser:named_node_for_range(
              { csrow - 1, cscol - 1, cerow - 1, cecol })
            if root_node then update_selection(root_node) end
            return
          end
          parent = parser:named_node_for_range(
            { csrow - 1, cscol - 1, cerow - 1, cecol })
          if not parent then return end
        end
        node = parent
        local srow, scol, erow, ecol = get_vim_range(node)
        if not (srow == csrow and scol == cscol and erow == cerow and ecol == cecol) then
          table.insert(selections[buf], node)
          update_selection(node)
          return
        end
      end
    end
  end

  -- <C-space> normal mode: init selection at cursor node
  vim.keymap.set('n', '<C-space>', function()
    local buf = vim.api.nvim_get_current_buf()
    local parser = vim.treesitter.get_parser(buf)
    if not parser then return end
    parser:parse()
    local node = vim.treesitter.get_node()
    if not node then return end
    selections[buf] = { node }
    update_selection(node)
  end, { silent = true, desc = 'Init treesitter selection' })

  -- <C-space> visual mode: expand to parent node
  vim.keymap.set('x', '<C-space>', select_incremental(function(node)
    return node:parent() or node
  end), { silent = true, desc = 'Expand treesitter selection' })

  -- <C-s> visual mode: expand to enclosing scope
  vim.keymap.set('x', '<C-s>', select_incremental(function(node)
    local parent = node:parent()
    if not parent then return node end
    while parent do
      local t = parent:type()
      if t:find('function') or t:find('method')
        or t:find('class') or t:find('module')
        or t:find('block') or t:find('body')
        or t:find('chunk') or t:find('program')
        or t:find('source_file') then
        return parent
      end
      parent = parent:parent()
    end
    return node:parent() or node
  end), { silent = true, desc = 'Expand to scope' })

  -- <BS> visual mode: shrink to previous selection (stack-based)
  vim.keymap.set('x', '<BS>', function()
    local buf = vim.api.nvim_get_current_buf()
    local nodes = selections[buf]
    if not nodes or #nodes < 2 then return end
    table.remove(selections[buf])
    local node = nodes[#nodes]
    update_selection(node)
  end, { silent = true, desc = 'Shrink treesitter selection' })
end

-- nvim-treesitter-textobjects setup (main branch)
local ok, ts_textobjects = pcall(require, 'nvim-treesitter-textobjects')
if ok then
  ts_textobjects.setup {
    select = {
      lookahead = true,
    },
    move = {
      set_jumps = true,
    },
  }

  -- Select keymaps
  vim.keymap.set({ 'x', 'o' }, 'aa', function()
    require('nvim-treesitter-textobjects.select').select_textobject('@parameter.outer', 'textobjects')
  end)
  vim.keymap.set({ 'x', 'o' }, 'ia', function()
    require('nvim-treesitter-textobjects.select').select_textobject('@parameter.inner', 'textobjects')
  end)
  vim.keymap.set({ 'x', 'o' }, 'af', function()
    require('nvim-treesitter-textobjects.select').select_textobject('@function.outer', 'textobjects')
  end)
  vim.keymap.set({ 'x', 'o' }, 'if', function()
    require('nvim-treesitter-textobjects.select').select_textobject('@function.inner', 'textobjects')
  end)
  vim.keymap.set({ 'x', 'o' }, 'ac', function()
    require('nvim-treesitter-textobjects.select').select_textobject('@class.outer', 'textobjects')
  end)
  vim.keymap.set({ 'x', 'o' }, 'ic', function()
    require('nvim-treesitter-textobjects.select').select_textobject('@class.inner', 'textobjects')
  end)

  -- Move keymaps
  vim.keymap.set({ 'n', 'x', 'o' }, ']m', function()
    require('nvim-treesitter-textobjects.move').goto_next_start('@function.outer', 'textobjects')
  end)
  vim.keymap.set({ 'n', 'x', 'o' }, ']]', function()
    require('nvim-treesitter-textobjects.move').goto_next_start('@class.outer', 'textobjects')
  end)
  vim.keymap.set({ 'n', 'x', 'o' }, ']M', function()
    require('nvim-treesitter-textobjects.move').goto_next_end('@function.outer', 'textobjects')
  end)
  vim.keymap.set({ 'n', 'x', 'o' }, '][', function()
    require('nvim-treesitter-textobjects.move').goto_next_end('@class.outer', 'textobjects')
  end)
  vim.keymap.set({ 'n', 'x', 'o' }, '[m', function()
    require('nvim-treesitter-textobjects.move').goto_previous_start('@function.outer', 'textobjects')
  end)
  vim.keymap.set({ 'n', 'x', 'o' }, '[[', function()
    require('nvim-treesitter-textobjects.move').goto_previous_start('@class.outer', 'textobjects')
  end)
  vim.keymap.set({ 'n', 'x', 'o' }, '[M', function()
    require('nvim-treesitter-textobjects.move').goto_previous_end('@function.outer', 'textobjects')
  end)
  vim.keymap.set({ 'n', 'x', 'o' }, '[]', function()
    require('nvim-treesitter-textobjects.move').goto_previous_end('@class.outer', 'textobjects')
  end)

  -- Swap keymaps
  vim.keymap.set('n', '<leader>a', function()
    require('nvim-treesitter-textobjects.swap').swap_next('@parameter.inner')
  end)
  vim.keymap.set('n', '<leader>A', function()
    require('nvim-treesitter-textobjects.swap').swap_previous('@parameter.inner')
  end)
end
