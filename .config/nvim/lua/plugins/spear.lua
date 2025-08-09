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
      '<leader>ld',
      function()
        require('spear').remove()
      end,
      desc = '[D]elete file from list',
    },
    {
      '<leader>lD',
      function()
        require('spear').delete()
      end,
      desc = '[D]elete list',
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
      '<leader>lu',
      function()
        require('spear.ui').open()
      end,
      desc = 'Spear UI',
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
