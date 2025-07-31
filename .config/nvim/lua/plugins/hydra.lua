return {
  'nvimtools/hydra.nvim',
  config = function()
    local Hydra = require 'hydra'
    Hydra {
      -- string? only used in auto-generated hint
      name = 'Window Hydra',

      -- string | string[] modes where the hydra exists, same as `vim.keymap.set()` accepts
      mode = 'n',

      -- string? key required to activate the hydra, when excluded, you can use
      -- Hydra:activate()
      body = '<C-w>',

      -- these are explained below
      hint = 'In window control Hydra',
      -- config = { ... },
      heads = {
        {
          '<',
          '<C-w><',
        },
        {
          '>',
          '<C-w>>',
        },
        {
          '+',
          '<C-w>+',
        },
        {
          '-',
          '<C-w>-',
        },
      },
    }
  end,
}
