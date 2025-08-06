---@module "lazy"
---@type LazyPluginSpec
return {
  -- See https://github.com/stevearc/overseer.nvim/pull/439
  'diego-velez/overseer.nvim',
  branch = 'task_output_filetype',
  cmd = {
    'OverseerOpen',
    'OverseerClose',
    'OverseerToggle',
    'OverseerSaveBundle',
    'OverseerLoadBundle',
    'OverseerDeleteBundle',
    'OverseerRunCmd',
    'OverseerRun',
    'OverseerInfo',
    'OverseerBuild',
    'OverseerQuickAction',
    'OverseerTaskAction',
    'OverseerClearCache',
  },
  keys = {
    { '<leader>ow', '<cmd>OverseerToggle<cr>', desc = 'Task list' },
    { '<leader>oo', '<cmd>OverseerRun<cr>', desc = 'Run task' },
    { '<leader>oq', '<cmd>OverseerQuickAction<cr>', desc = 'Action recent task' },
    { '<leader>oi', '<cmd>OverseerInfo<cr>', desc = 'Overseer Info' },
    { '<leader>ob', '<cmd>OverseerBuild<cr>', desc = 'Task builder' },
    { '<leader>ot', '<cmd>OverseerTaskAction<cr>', desc = 'Task action' },
    { '<leader>oc', '<cmd>OverseerClearCache<cr>', desc = 'Clear cache' },
  },
  ---@module 'overseer'
  ---@type overseer.Config
  opts = {
    templates = {
      'builtin',
      'java',
      'skaffold',
    },
    dap = false,
    task_list = {
      bindings = {
        ['?'] = 'ShowHelp',
        ['g?'] = 'ShowHelp',
        ['<CR>'] = 'RunAction',
        ['<C-e>'] = 'Edit',
        ['o'] = 'Open',
        ['<C-v>'] = 'OpenVsplit!',
        ['<C-h>'] = 'OpenSplit',
        ['<C-f>'] = 'OpenFloat',
        ['<C-q>'] = 'OpenQuickFix',
        ['p'] = 'TogglePreview',
        ['<C-right>'] = false,
        ['<C-left>'] = false,
        ['<C-down>'] = 'IncreaseAllDetail',
        ['<C-up>'] = 'DecreaseAllDetail',
        ['{'] = 'DecreaseWidth',
        ['}'] = 'IncreaseWidth',
        ['['] = 'PrevTask',
        [']'] = 'NextTask',
        ['<C-u>'] = 'ScrollOutputUp',
        ['<C-d>'] = 'ScrollOutputDown',
        ['q'] = 'Close',
      },
    },
    form = {
      win_opts = {
        winblend = 0,
      },
    },
    confirm = {
      win_opts = {
        winblend = 0,
      },
    },
    task_win = {
      win_opts = {
        winblend = 0,
      },
    },
  },
}
