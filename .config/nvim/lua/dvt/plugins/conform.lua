return { -- Autoformat
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format { async = true, lsp_fallback = true }
      end,
      desc = '[F]ormat buffer',
    },
    {
      '<leader>tf',
      function()
        vim.g.enable_autoformat = not vim.g.enable_autoformat

        if vim.g.enable_autoformat then
          require('fidget').notify('Autoformatting enabled', nil, { key = 'toggle_autoformatting' })
        else
          require('fidget').notify('Autoformatting disabled', nil, { key = 'toggle_autoformatting' })
        end
      end,
      desc = 'Toggle auto formatting',
    },
  },
  opts = {
    notify_on_error = true,
    format_on_save = function(bufnr)
      -- Do not autoformat if it is disabled
      if not vim.g.enable_autoformat then
        return
      end

      -- Disable "format_on_save lsp_fallback" for languages that don't
      -- have a well standardized coding style. You can add additional
      -- languages here or re-enable it for the disabled ones.
      local disable_filetypes = { c = true, cpp = true }
      return {
        timeout_ms = 500,
        lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
      }
    end,
    formatters_by_ft = {
      lua = { 'stylua' },
      templ = { 'templ' },
      html = { 'prettier' },
      markdown = { 'prettier' },
      typescriptreact = { 'prettier' },
      -- Conform can also run multiple formatters sequentially
      -- python = { "isort", "black" },
      --
      -- You can use 'stop_after_first' to run the first available formatter from the list
      -- javascript = { "prettierd", "prettier", stop_after_first = true },
    },
  },
  init = function()
    -- I want to be able to toggle autoformatting on save
    -- See https://github.com/stevearc/conform.nvim/blob/master/doc/recipes.md#command-to-toggle-format-on-save
    vim.g.enable_autoformat = true
  end,
}
