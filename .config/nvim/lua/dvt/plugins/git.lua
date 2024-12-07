return {
  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      current_line_blame_opts = {
        delay = 0,
      },
      preview_config = {
        border = 'rounded',
      },
      on_attach = function(bufnr)
        local gitsigns = require 'gitsigns'

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end

        -- Hunk Navigation
        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal { '[c', bang = true }
          else
            gitsigns.nav_hunk 'prev'
          end
        end, 'Previous Git [c]hange')

        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal { ']c', bang = true }
          else
            gitsigns.nav_hunk 'next'
          end
        end, 'Next Git [c]hange')

        -- Hunk Actions
        map('n', '<leader>gs', gitsigns.stage_hunk, '[S]tage hunk')
        map('v', '<leader>gs', function()
          gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, '[S]tage hunk')
        map('n', '<leader>gu', gitsigns.undo_stage_hunk, '[U]nstage previous staged hunk')
        map('n', '<leader>gr', gitsigns.reset_hunk, '[R]eset hunk')
        map('v', '<leader>gr', function()
          gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, '[R]eset hunk')
        map('n', '<leader>gp', gitsigns.preview_hunk, '[P]review hunk')

        -- Buffer Actions
        map('n', '<leader>gS', gitsigns.stage_buffer, '[S]tage buffer')
        map('n', '<leader>gR', gitsigns.reset_buffer, '[R]eset buffer')

        -- Diffing
        map('n', '<leader>gd', gitsigns.diffthis, '[D]iff against head')
        map('n', '<leader>gD', function()
          gitsigns.diffthis '~'
        end, '[D]iff against previous commit')

        -- Blame
        map('n', '<leader>gb', gitsigns.toggle_current_line_blame, 'Toggle [b]lame')
        map('n', '<leader>gB', function()
          gitsigns.blame_line { full = true }
        end, 'Show [b]lame')

        -- Text object
        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', 'Git [h]unk')
      end,
    },
  },
  {
    'kdheepak/lazygit.nvim',
    lazy = true,
    cmd = {
      'LazyGit',
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    keys = {
      { '<leader>gl', ':LazyGit<cr>', desc = 'LazyGit' },
    },
  },
  {
    'akinsho/git-conflict.nvim',
    version = '*',
    dependencies = {
      'Mofiqul/dracula.nvim',
    },
    init = function()
      local colors = require('dracula').colors()
      vim.api.nvim_set_hl(
        0,
        'GitConflictIncomingLabel',
        { fg = colors.bg, bg = colors.bright_green, bold = true, italic = true }
      )
      vim.api.nvim_set_hl(0, 'GitConflictIncoming', { fg = colors.green })
      vim.api.nvim_set_hl(0, 'GitConflictCurrent', { fg = colors.red })
      vim.api.nvim_set_hl(
        0,
        'GitConflictCurrentLabel',
        { fg = colors.bg, bg = colors.bright_red, bold = true, italic = true }
      )
    end,
    opts = true,
  },
}
