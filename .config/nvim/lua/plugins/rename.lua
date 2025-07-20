return {
  'saecki/live-rename.nvim',
  keys = {
    {
      '<leader>cr',
      function()
        require('live-rename').rename { insert = true }
      end,
      desc = 'LSP: [R]ename',
    },
  },
}
