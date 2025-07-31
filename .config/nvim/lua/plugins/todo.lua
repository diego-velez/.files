return {
  -- Highlight todo, notes, etc in comments
  'folke/todo-comments.nvim',
  event = 'VimEnter',
  dependencies = { 'nvim-lua/plenary.nvim' },
  keys = {
    {
      '[t',
      function()
        require('todo-comments').jump_prev()
      end,
      desc = 'Previous [t]odo comment',
    },
    {
      ']t',
      function()
        require('todo-comments').jump_next()
      end,
      desc = 'Next [t]odo comment',
    },
  },
  opts = { signs = true },
}
