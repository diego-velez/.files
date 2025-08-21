require('zen-mode').setup {
  plugins = {
    wezterm = {
      enabled = true,
    },
  },
  on_open = function(win)
    vim.schedule(function()
      vim.g.og_scrolloff = vim.o.scrolloff
      vim.o.scrolloff = math.floor(vim.o.scrolloff / 2)
      vim.g.mininotify_disable = true
      MiniClue.disable_all_triggers()
      MiniPick.config.window.old_config = MiniPick.config.window.config
      MiniPick.config.window.config = function()
        local height = vim.api.nvim_win_get_height(win)
        local width = vim.api.nvim_win_get_width(win)
        return {
          relative = 'editor',
          anchor = 'NW',
          height = height,
          width = width,
          row = 0,
          col = math.floor(vim.o.columns * 0.2) + 1,
        }
      end
    end)
  end,
  on_close = function()
    vim.schedule(function()
      vim.o.scrolloff = vim.g.og_scrolloff
      vim.g.og_scrolloff = nil
      vim.g.mininotify_disable = false
      MiniClue.enable_all_triggers()
      MiniPick.config.window.config = MiniPick.config.window.old_config
      MiniPick.config.window.old_config = nil
    end)
  end,
}

vim.keymap.set('n', '<leader>tz', require('zen-mode').toggle, { desc = 'Toggle [Zen]' })
