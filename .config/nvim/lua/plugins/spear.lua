return {
  'diego-velez/spear.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  keys = {
    {
      '<leader>la',
      function()
        require('spear').add()
      end,
      desc = '[A]dd file to list',
    },
    {
      '<leader>lc',
      function()
        require('spear').create()
      end,
      desc = '[C]reate list',
    },
    {
      '<leader>lr',
      function()
        require('spear').rename()
      end,
      desc = '[R]ename list',
    },
    {
      '<leader>ls',
      function()
        require('spear').switch()
      end,
      desc = '[S]witch list',
    },
    {
      '<A-n>',
      function()
        require('spear').select(1)
      end,
    },
    {
      '<A-e>',
      function()
        require('spear').select(2)
      end,
    },
    {
      '<A-i>',
      function()
        require('spear').select(3)
      end,
    },
    {
      '<A-o>',
      function()
        require('spear').select(4)
      end,
    },
  },
  opts = {},
}
