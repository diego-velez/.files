return {
  'folke/edgy.nvim',
  event = 'VeryLazy',
  init = function()
    vim.o.laststatus = 3
    vim.o.splitkeep = 'screen'
  end,
  ---@module "edgy"
  ---@type Edgy.Config
  opts = {
    bottom = {
      'Trouble',
      { ft = 'qf', title = 'QuickFix', open = 'copen' },
    },
    right = {
      {
        title = 'Grug Far',
        ft = 'grug-far',
        size = { width = 0.3 },
      },
      {
        title = 'Overseer',
        ft = 'OverseerList',
      },
    },
  },
}
