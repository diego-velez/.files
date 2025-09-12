-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Smart cursor line
local smart_cursor = vim.api.nvim_create_augroup('Smart cursor', { clear = true })
vim.api.nvim_create_autocmd('InsertLeave', {
  group = smart_cursor,
  command = 'set cursorline',
})

vim.api.nvim_create_autocmd('InsertEnter', {
  group = smart_cursor,
  command = 'set nocursorline',
})

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('Disable new line comment', { clear = true }),
  desc = 'Disable new line comment',
  pattern = '*',
  callback = function()
    vim.opt.formatoptions:remove { 'c', 'r', 'o' }
  end,
})

vim.api.nvim_create_autocmd('FocusGained', {
  group = vim.api.nvim_create_augroup('Update file on change', { clear = true }),
  desc = 'Update file when it changes',
  command = 'checktime',
})

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('Enable wrap/spell', { clear = true }),
  desc = 'Enable wrap and spell in these filetypes',
  pattern = { 'gitcommit', 'markdown', 'text', 'log', 'typst' },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

vim.api.nvim_create_autocmd('BufReadPre', {
  group = vim.api.nvim_create_augroup('Clear search', { clear = true }),
  desc = 'Clear the last used search pattern when opening a new buffer',
  pattern = '*',
  callback = function()
    vim.fn.setreg('/', '') -- Clears the search register
    vim.cmd 'let @/ = ""' -- Clear the search register using Vim command
  end,
})
