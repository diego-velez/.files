vim.opt_local.wrap = true
vim.opt_local.spell = true

vim.keymap.set(
  'n',
  '<leader>r',
  vim.cmd.TypstPreview,
  { buffer = 0, desc = '[R]un Preview in Browser' }
)
