return {
  'MagicDuck/grug-far.nvim',
  cmd = 'GrugFar',
  keys = {
    {
      '<leader>sR',
      function()
        local grug = require 'grug-far'
        local ext = vim.bo.buftype == '' and vim.fn.expand '%:e'
        grug.open {
          transient = true,
          prefills = {
            filesFilter = ext and ext ~= '' and '*.' .. ext or nil,
          },
        }
      end,
      mode = { 'n', 'v' },
      desc = '[S]earch and [R]eplace',
    },
  },
  opts = {
    keymaps = {
      nextInput = { n = '<tab>', i = '<tab>' },
      prevInput = { n = '<s-tab>', i = '<s-tab>' },
    },
  },
}
