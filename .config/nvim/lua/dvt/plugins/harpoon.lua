return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local harpoon = require 'harpoon'
    harpoon:setup()

    vim.keymap.set('n', '<leader>ha', function()
      harpoon:list():add()
    end, { desc = 'Harpoon [a]ppend' })

    vim.keymap.set('n', '<leader>hu', function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = 'Harpoon [U]I' })

    vim.keymap.set('n', '<A-n>', function()
      harpoon:list():select(1)
    end)
    vim.keymap.set('n', '<A-e>', function()
      harpoon:list():select(2)
    end)
    vim.keymap.set('n', '<A-i>', function()
      harpoon:list():select(3)
    end)
    vim.keymap.set('n', '<A-o>', function()
      harpoon:list():select(4)
    end)

    -- NOTE: Setup harpoon window highlight groups
    local dracula = require('dracula').colors()
    vim.api.nvim_set_hl(0, 'HarpoonNormal', { fg = dracula.fg, bg = dracula.menu })
    vim.api.nvim_set_hl(0, 'HarpoonBorder', { fg = dracula.purple, bg = dracula.menu })
    vim.api.nvim_set_hl(0, 'HarpoonTitle', { fg = dracula.white, bg = dracula.menu })

    -- This was taken from mini.pick :)
    local win_update_hl = function(win_id, new_from, new_to)
      local new_entry = new_from .. ':' .. new_to
      local replace_pattern = string.format('(%s:[^,]*)', vim.pesc(new_from))
      local new_winhighlight, n_replace =
        vim.wo[win_id].winhighlight:gsub(replace_pattern, new_entry)
      if n_replace == 0 then
        new_winhighlight = new_winhighlight .. ',' .. new_entry
      end

      vim.wo[win_id].winhighlight = new_winhighlight
    end

    harpoon:extend {
      -- NOTE: cx has the following properties
      -- win_id = win_id,
      -- bufnr = bufnr,
      -- current_file = current_file,
      UI_CREATE = function(cx)
        vim.keymap.set('n', '<C-v>', function()
          harpoon.ui:select_menu_item { vsplit = true }
        end, { buffer = cx.bufnr })

        vim.keymap.set('n', '<C-h>', function()
          harpoon.ui:select_menu_item { split = true }
        end, { buffer = cx.bufnr })

        win_update_hl(cx.win_id, 'NormalFloat', 'HarpoonNormal')
        win_update_hl(cx.win_id, 'FloatBorder', 'HarpoonBorder')
        win_update_hl(cx.win_id, 'FloatTitle', 'HarpoonTitle')
      end,
    }
  end,
}
