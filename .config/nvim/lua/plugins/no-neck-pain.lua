require('no-neck-pain').setup {
  width = 115,
  autocmds = {
    enableOnVimEnter = true,
    skipEnteringNoNeckPainBuffer = true,
  },
}

vim.keymap.set('n', '<leader>tn', '<cmd>NoNeckPain<cr>', { desc = 'Toggle No [N]eck Pain' })
