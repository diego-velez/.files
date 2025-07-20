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
