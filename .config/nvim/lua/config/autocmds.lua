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

-- Autocommands for focus.nvim
local ignore_filetypes = {
  'neo-tree',
  'qf',
  'minipick',
  'minifiles',
  'ministarter',
  'OverseerListOutput',
  'OverseerList',
  'grug-far',
  'undotree',
  'diff', -- undotree diff window
  'vim', -- q:
}
local ignore_buftypes = { 'nofile', 'prompt', 'popup', 'nowrite' }

local augroup = vim.api.nvim_create_augroup('FocusDisable', { clear = true })

vim.api.nvim_create_autocmd('WinEnter', {
  group = augroup,
  callback = function(_)
    vim.w.focus_disable = vim.tbl_contains(ignore_buftypes, vim.bo.buftype)
  end,
  desc = 'Disable focus autoresize for BufType',
})

vim.api.nvim_create_autocmd('FileType', {
  group = augroup,
  callback = function(_)
    vim.w.focus_disable = vim.tbl_contains(ignore_filetypes, vim.bo.filetype)
  end,
  desc = 'Disable focus autoresize for FileType',
})

vim.api.nvim_create_autocmd('FileType', {
  desc = 'Typst specific options',
  pattern = 'typst',
  callback = function(args)
    vim.opt_local.wrap = true
    vim.opt_local.spell = true

    vim.keymap.set(
      'n',
      '<leader>r',
      '<cmd>TypstPreview<cr>',
      { buffer = args.buf, desc = '[R]un Preview in Browser' }
    )
  end,
})
