---@module "lazy"
---@type LazySpec[]
return {
  {
    'Mofiqul/dracula.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      italic_comment = true,
      overrides = function(colors)
        return {
          -- Setup mini.statusline
          MiniStatuslineInactive = { fg = colors.white, bg = colors.menu, bold = true },

          -- Setup mini.pick
          MiniFilesBorder = { fg = colors.purple, bg = colors.menu },
          MiniFilesBorderModified = { fg = colors.yellow, bg = colors.menu },
          MiniFilesCursorLine = { fg = colors.white, bg = colors.bg },
          MiniFilesNormal = { fg = 'fg', bg = colors.menu },
          MiniFilesTitle = { fg = colors.white, bg = colors.menu },
          MiniFilesTitleFocused = { fg = 'fg', bg = colors.menu },

          -- Setup mini.starter
          MiniStarterCurrent = { fg = colors.fg, bg = 'bg' },
          MiniStarterHeader = { fg = colors.green, bg = 'bg' },
          MiniStarterFooter = { fg = colors.green, bg = 'bg' },
          MiniStarterItem = { fg = colors.white, bg = 'bg' },
          MiniStarterItemBullet = { fg = colors.cyan, bg = 'bg' },
          MiniStarterSection = { fg = colors.cyan, bg = 'bg' },

          -- Setup mini.pick
          MiniPickBorder = { fg = colors.purple, bg = colors.menu },
          MiniPickBorderText = { fg = colors.white, bg = colors.menu },
          MiniPickPrompt = { fg = colors.purple, bg = colors.menu },
          MiniPickMatchCurrent = { fg = colors.white, bg = colors.bg },
          MiniPickMatchRanges = { fg = colors.green, bg = colors.menu },
          MiniPickNormal = { fg = 'fg', bg = colors.menu },

          -- Setup mini.clue
          MiniClueBorder = { fg = colors.purple, bg = colors.menu },
          MiniClueDescGroup = { fg = colors.green, bg = colors.menu },
          MiniClueDescSingle = { fg = 'fg', bg = colors.menu },
          MiniClueNextKey = { fg = colors.cyan, bg = colors.menu },
          MiniClueNextKeyWithPostkeys = { fg = colors.cyan, bg = colors.menu },
          MiniClueSeparator = { fg = colors.cyan, bg = colors.menu },
          MiniClueTitle = { fg = colors.white, bg = colors.menu },

          -- Setup mini.notify
          MiniNotifyNormal = { fg = 'fg', bg = colors.menu },
          MiniNotifyBorder = { fg = colors.purple, bg = colors.menu },
          MiniNotifyTitle = { fg = colors.white, bg = colors.menu },

          -- Setup mini.trailspace
          MiniTrailspace = { bg = colors.bright_red },

          -- Setup harpoon window highlight groups
          HarpoonNormal = { fg = colors.fg, bg = colors.menu },
          HarpoonBorder = { fg = colors.purple, bg = colors.menu },
          HarpoonTitle = { fg = colors.white, bg = colors.menu },

          -- Setup gitconflict
          GitConflictIncomingLabel = {
            fg = colors.bg,
            bg = colors.bright_green,
            bold = true,
            italic = true,
          },
          GitConflictIncoming = { fg = colors.green },
          GitConflictCurrent = { fg = colors.red },
          GitConflictCurrentLabel = {
            fg = colors.bg,
            bg = colors.bright_red,
            bold = true,
            italic = true,
          },
        }
      end,
    },
    config = function(_, opts)
      require('dracula').setup(opts)
      vim.cmd.colorscheme 'dracula'
    end,
  },
  {
    'wnkz/monoglow.nvim',
    lazy = false,
    priority = 1000,
    opts = {
      on_highlights = function(highlights, colors)
        -- Setup mini.statusline
        vim.api.nvim_set_hl(
          0,
          'MiniStatuslineModeNormal',
          { fg = colors.gray8, bg = colors.bg_statusline }
        )
        vim.api.nvim_set_hl(0, 'MiniStatuslineModeInsert', { fg = colors.black, bg = colors.glow })
        vim.api.nvim_set_hl(0, 'MiniStatuslineModeVisual', { fg = colors.black, bg = colors.gray9 })
        vim.api.nvim_set_hl(
          0,
          'MiniStatuslineModeReplace',
          { fg = colors.black, bg = colors.gray9 }
        )
        vim.api.nvim_set_hl(0, 'MiniStatuslineModeCommand', { fg = colors.black, bg = colors.glow })
        vim.api.nvim_set_hl(0, 'MiniStatuslineInactive', { fg = colors.bg, bg = colors.bg })
      end,
    },
    config = function(_, opts)
      require('monoglow').setup(opts)
    end,
  },
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    opts = {},
    config = function(_, opts)
      require('tokyonight').setup(opts)
    end,
  },
  {
    'navarasu/onedark.nvim',
    opts = {
      style = 'deep',
    },
  },
  {
    'rose-pine/neovim',
    name = 'rose-pine',
  },
  {
    'dgox16/oldworld.nvim',
    lazy = false,
    priority = 1000,
  },
  {
    'mcauley-penney/techbase.nvim',
    lazy = false,
    priority = 1000,
  },
}
