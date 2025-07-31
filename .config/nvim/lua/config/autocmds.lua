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
  desc = 'Enable wrap in these filetypes',
  pattern = { 'gitcommit', 'markdown', 'text', 'log' },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})
