return {
  'rachartier/tiny-inline-diagnostic.nvim',
  event = 'VeryLazy',
  priority = 1000,
  opts = {
    options = {
      use_icons_from_diagnostic = true,
      multilines = true,
      show_all_diag_under_cursor = true,
    },
    signs = {
      left = ' ',
      right = '',
      diag = '󰧟',
      arrow = '    ',
      up_arrow = '    ',
      vertical = ' │',
      vertical_end = ' └',
    },
  },
  config = function(_, opts)
    vim.diagnostic.config { virtual_text = false }
    require('tiny-inline-diagnostic').setup(opts)
  end,
}
