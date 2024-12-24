return {
  'Mofiqul/dracula.nvim',
  priority = 1000,
  lazy = false,
  opts = {
    italic_comment = true,
  },
  config = function(_, opts)
    require('dracula').setup(opts)
    vim.cmd.colorscheme 'dracula'
  end,
}
