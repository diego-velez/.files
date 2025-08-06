---@module "lazy"
---@type LazyPluginSpec[]
return {
  {
    -- Detect tabstop and shiftwidth automatically
    'NMAC427/guess-indent.nvim',
    opts = {},
  },
  {
    'lambdalisue/vim-suda',
    cmd = { 'SudaRead', 'SudaWrite' },
  },
  {
    'sphamba/smear-cursor.nvim',
    opts = {},
  },
  {
    'chomosuke/typst-preview.nvim',
    ft = 'typst',
    version = '1.*',
    opts = {
      -- WARN: zen-browser must be in PATH and link to zen binary
      open_cmd = 'zen-browser %s --class typst-preview',
    },
  },
  {
    'mistweaverco/kulala.nvim',
    --stylua: ignore
    keys = {
      {'<leader>r', '', desc = '[R]un'},
      { '<leader>rs', function() require('kulala').run() end, ft = {'http', 'rest'}, desc = '[S]end request' },
      { '<leader>ra', function() require('kulala').run_all() end, ft = {'http', 'rest'}, desc = 'Send [A]ll requests' },
      { '<leader>rp', function() require('kulala').replay() end, ft = {'http', 'rest'}, desc = 'Run [P]revious' },
      { '<leader>ru', function() require('kulala').toggle_view() end, ft = {'http', 'rest'}, desc = 'Toggle UI' },
      { '{', function() require('kulala').jump_prev() end, ft = {'http', 'rest'}, desc = 'Previous Request' },
      { '}', function() require('kulala').jump_next() end, ft = {'http', 'rest'}, desc = 'Next Request' },
    },
    ft = { 'http', 'rest' },
    opts = {
      global_keymaps = false,
      global_keymaps_prefix = '',
      kulala_keymaps_prefix = '',
    },
  },
}
