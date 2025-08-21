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
