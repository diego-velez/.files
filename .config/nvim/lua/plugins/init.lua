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
}
