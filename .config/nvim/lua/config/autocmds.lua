-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Smart cursor line
vim.api.nvim_create_autocmd('InsertLeave', {
  command = 'set cursorline',
})

vim.api.nvim_create_autocmd('InsertEnter', {
  command = 'set nocursorline',
})

vim.api.nvim_create_autocmd('FileType', {
  desc = 'Disable new line comment',
  pattern = '*',
  callback = function()
    vim.opt.formatoptions:remove { 'c', 'r', 'o' }
  end,
})

vim.api.nvim_create_autocmd('FocusGained', {
  desc = 'Update file when it changes',
  command = 'checktime',
})

vim.api.nvim_create_autocmd('FileType', {
  desc = 'Enable wrap and spell in these filetypes',
  pattern = { 'gitcommit', 'markdown', 'text', 'log', 'typst' },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

vim.api.nvim_create_autocmd('BufReadPre', {
  desc = 'Clear the last used search pattern when opening a new buffer',
  pattern = '*',
  callback = function()
    vim.fn.setreg('/', '') -- Clears the search register
    vim.cmd 'let @/ = ""' -- Clear the search register using Vim command
  end,
})
