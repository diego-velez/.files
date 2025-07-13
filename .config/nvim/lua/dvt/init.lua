require 'dvt.keymaps'
require 'dvt.settings'
require 'dvt.lazy_init'
require 'dvt.health'

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Configure diagnostics
-- Change diagnostic symbols in the sign column (gutter)
local signs = { ERROR = '', WARN = '', HINT = '', INFO = '' }
local diagnostic_signs = {}
for type, icon in pairs(signs) do
  diagnostic_signs[vim.diagnostic.severity[type]] = icon
end

vim.diagnostic.config {
  float = { border = 'rounded' },
  signs = { text = diagnostic_signs },
}

-- Setup git variables if working on a directory tracked by my dotfiles repo
local home = vim.fn.getenv 'HOME'
local git_dir = home .. '/.files'
local work_tree = home
local dotfiles_files = vim
  .system({
    'git',
    '--git-dir=' .. git_dir,
    '--work-tree=' .. work_tree,
    'ls-files',
    '--full-name',
    '/home/dvt',
  }, { text = true })
  :wait()
local cwd = vim.fn.getcwd()
cwd = string.sub(cwd, #home + 2)
if cwd ~= nil and string.find(dotfiles_files.stdout, cwd, 1, true) ~= nil then
  vim.env.GIT_WORK_TREE = '/home/dvt'
  vim.env.GIT_DIR = '/home/dvt/.files'
end
