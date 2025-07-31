return {
  'mbbill/undotree',
  keys = {
    {
      '<leader>tu',
      vim.cmd.UndotreeToggle,
      desc = 'Toggle [u]ndo tree',
    },
  },
  config = function()
    vim.g.undotree_WindowLayout = 2
    vim.g.undotree_SetFocusWhenToggle = 1
  end,
}
