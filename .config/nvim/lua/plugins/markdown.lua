---@module "lazy"
---@type LazyPluginSpec
return {
  'MeanderingProgrammer/render-markdown.nvim',
  ft = 'markdown',
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' },
  ---@module "render-markdown"
  ---@type render.md.UserConfig
  opts = {
    on = {
      render = function()
        vim.opt_local.colorcolumn = '80'
      end,
    },
  },
}
