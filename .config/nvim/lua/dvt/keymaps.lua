-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<ESC>', ':nohlsearch<CR>')

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

------ DVT's keymaps -------
-- Keep cursor centered
vim.keymap.set('n', '<C-d>', function()
  vim.cmd.normal { '\4', bang = true }
  MiniAnimate.execute_after('scroll', 'normal! zz')
end)
vim.keymap.set('n', '<C-u>', function()
  vim.cmd.normal { '\21', bang = true }
  MiniAnimate.execute_after('scroll', 'normal! zz')
end)
vim.keymap.set('n', 'n', function()
  vim.cmd.normal { 'n', bang = true }
  MiniAnimate.execute_after('scroll', 'normal! zzzv')
end)
vim.keymap.set('n', 'N', function()
  vim.cmd.normal { 'N', bang = true }
  MiniAnimate.execute_after('scroll', 'normal! zzzv')
end)
vim.keymap.set('n', 'G', function()
  vim.cmd.normal { 'G', bang = true }
  MiniAnimate.execute_after('scroll', 'normal! zz')
end)

-- Move line up or down
vim.keymap.set('n', 'j', "v:move '<-2<CR>gv=gv<ESC>")
vim.keymap.set('n', 'k', "v:move '>+1<CR>gv=gv<ESC>")
vim.keymap.set('x', 'j', ":move '<-2<CR>gv=gv")
vim.keymap.set('x', 'k', ":move '>+1<CR>gv=gv")

-- Have cursor stay in place when joining lines together
vim.keymap.set('n', 'J', 'mzJ`z')

-- Stop automatically copying
vim.keymap.set('x', 'p', [["_dp]])
vim.keymap.set('n', 'C', '"_C')

-- Disable Q because apparently it's trash lmao
vim.keymap.set('n', 'Q', '<nop>')

-- Rename the word my cursor is on using vim's substitute thing
vim.keymap.set('n', '<leader>rs', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- Show hover with window
vim.api.nvim_create_autocmd({ 'VimEnter', 'VimResized' }, {
  group = vim.api.nvim_create_augroup('DVT Hover', { clear = true }),
  desc = 'Setup LSP hover window',
  callback = function()
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.3)

    vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
      border = 'rounded',
      max_width = width,
      max_height = height,
    })
  end,
})

vim.keymap.set('n', 'h', vim.lsp.buf.hover)
vim.keymap.set('n', 'K', '<nop>')

-- Quickfix keymaps
vim.keymap.set('n', '<S-up>', ':cprevious<cr>')
vim.keymap.set('n', '<S-down>', ':cnext<cr>')

-- Remap the completion keymaps in cmdline mode
vim.keymap.set('c', '<Up>', '<C-p>')
vim.keymap.set('c', '<Down>', '<C-n>')
vim.keymap.set('c', '<C-CR>', '<C-y>')
