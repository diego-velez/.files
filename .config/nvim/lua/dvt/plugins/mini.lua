return { -- Collection of various small independent plugins/modules
  'echasnovski/mini.nvim',
  dependencies = {
    'nvim-treesitter/nvim-treesitter-textobjects',
  },
  init = function()
    vim.g.highlighting_enabled = true

    package.preload['nvim-web-devicons'] = function()
      require('mini.icons').mock_nvim_web_devicons()
      return package.loaded['nvim-web-devicons']
    end
  end,
  keys = {
    {
      '<leader>th',
      function()
        require('mini.hipatterns').toggle(0)
        vim.g.highlighting_enabled = not vim.g.highlighting_enabled

        if vim.g.highlighting_enabled then
          require('fidget').notify(
            'Highlighting enabled',
            nil,
            { key = 'toggle_highlight', annote = 'toggle' }
          )
        else
          require('fidget').notify(
            'Highlighting disabled',
            nil,
            { key = 'toggle_highlight', annote = 'toggle' }
          )
        end
      end,
      desc = 'Toggle [H]ighlighting',
    },
  },
  config = function()
    -- NOTE: Start mini.icons configuration
    require('mini.icons').setup()

    -- NOTE: Start mini.hipatterns configuration
    local patterns = require 'mini.hipatterns'
    patterns.setup {
      highlighters = {
        hex_color = patterns.gen_highlighter.hex_color { priority = 2000 },
        shorthand = {
          pattern = '()#%x%x%x()%f[^%x%w]',
          group = function(_, _, data)
            ---@type string
            local match = data.full_match
            local r, g, b = match:sub(2, 2), match:sub(3, 3), match:sub(4, 4)
            local hex_color = '#' .. r .. r .. g .. g .. b .. b

            return patterns.compute_hex_color_group(hex_color, 'bg')
          end,
          extmark_opts = { priority = 2000 },
        },
      },
    }

    -- NOTE: Start mini.ai configuration
    --
    -- Better Around/Inside textobjects
    --
    -- Examples:
    --  - va)  - [V]isually select [A]round [)]paren
    --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
    --  - ci'  - [C]hange [I]nside [']quote
    local ai = require 'mini.ai'
    require('mini.ai').setup {
      n_lines = 500,
      custom_textobjects = {
        -- [F]unction
        f = ai.gen_spec.treesitter { a = '@function.outer', i = '@function.inner' },

        -- Entire [B]uffer
        b = function()
          local from = { line = 1, col = 1 }
          local to = {
            line = vim.fn.line '$',
            col = math.max(vim.fn.getline('$'):len(), 1),
          }
          return { from = from, to = to }
        end,

        -- [C]ode
        c = ai.gen_spec.treesitter {
          a = { '@block.outer', '@conditional.outer', '@loop.outer' },
          i = { '@block.inner', '@conditional.inner', '@loop.inner' },
        },

        -- [I]nvokation
        i = ai.gen_spec.function_call(),

        -- [D]igits
        d = { '%f[%d]%d+' },
      },
    }

    -- NOTE: Start mini.surround configuration
    --
    -- Add/delete/replace surroundings (brackets, quotes, etc.)
    --
    -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
    -- - sd'   - [S]urround [D]elete [']quotes
    -- - sr)'  - [S]urround [R]eplace [)] [']
    require('mini.surround').setup {
      -- Use Ctrl-s for all things surround
      mappings = {
        add = 'ys',
        delete = 'ds',
        find = '',
        find_left = '',
        highlight = '',
        replace = 'cs',
        update_n_lines = '',
      },
    }

    -- Remap adding surrounding to Visual mode selection
    vim.keymap.del('x', 'ys')
    vim.keymap.set('x', 's', [[:<C-u>lua MiniSurround.add('visual')<CR>]], { silent = true })

    -- Make special mapping for "add surrounding for line"
    vim.keymap.set('n', 'yss', 'ys_', { remap = true })

    -- NOTE: Start mini.statusline configuration
    local function statuslineActive()
      local section_fileinfo = function(args)
        local filetype = vim.bo.filetype

        -- Don't show anything if there is no filetype
        if filetype == '' then
          return ''
        end

        -- Add filetype icon
        local icon, highlight, _ = MiniIcons.get('filetype', filetype)
        filetype = icon .. ' ' .. filetype

        -- Construct output string if truncated or buffer is not normal
        if MiniStatusline.is_truncated(args.trunc_width) or vim.bo.buftype ~= '' then
          return filetype, highlight
        end

        local get_filesize = function()
          local size = vim.fn.getfsize(vim.fn.getreg '%')
          if size < 1024 then
            return string.format('%dB', size)
          elseif size < 1048576 then
            return string.format('%.2fKB', size / 1024)
          else
            return string.format('%.2fMB', size / 1048576)
          end
        end

        -- Construct output string with extra file info
        local size = get_filesize()

        return string.format('%s %s', filetype, size), highlight
      end

      local mode, mode_hl = MiniStatusline.section_mode { trunc_width = 120 }
      local git = MiniStatusline.section_git { trunc_width = 40 }
      local diff = MiniStatusline.section_diff { trunc_width = 75 }
      local diagnostics = MiniStatusline.section_diagnostics { trunc_width = 75 }
      local lsp = MiniStatusline.section_lsp { trunc_width = 75 }
      local filename = MiniStatusline.section_filename { trunc_width = 140 }

      local fileinfo, fileinfo_hl = section_fileinfo { trunc_width = 75 }
      local location = '%2l:%-2v'
      local search = MiniStatusline.section_searchcount { trunc_width = 75 }

      local combine_groups = function(groups)
        local parts = vim.tbl_map(function(s)
          if type(s) == 'string' then
            return s
          end
          if type(s) ~= 'table' then
            return ''
          end

          local string_arr = vim.tbl_filter(function(x)
            return type(x) == 'string' and x ~= ''
          end, s.strings or {})
          local str = table.concat(string_arr, ' ')

          -- Use previous highlight group
          if s.hl == nil then
            return ' ' .. str .. ' '
          end

          -- Allow using this highlight group later
          if str:len() == 0 then
            return '%#' .. s.hl .. '#'
          end

          return string.format('%%#%s#%s', s.hl, str)
        end, groups)

        return table.concat(parts, '')
      end

      local invertHighlightGroup = function(hl_name, hl_colors)
        local hl_name_inverted = hl_name .. 'Invert'

        if hl_colors.reverse then
          vim.api.nvim_set_hl(0, hl_name_inverted, {})
        elseif hl_colors.bg and not hl_colors.fg then
          vim.api.nvim_set_hl(0, hl_name_inverted, { fg = hl_colors.bg, bg = 'bg' })
        elseif hl_colors.fg and not hl_colors.bg then
          vim.api.nvim_set_hl(0, hl_name_inverted, { fg = 'bg', bg = 'bg' })
        else
          vim.api.nvim_set_hl(0, hl_name_inverted, { fg = hl_colors.bg, bg = 'bg' })
        end
        return hl_name_inverted
      end

      -- Invert colors
      local mode_hl_colors = vim.api.nvim_get_hl(0, { name = mode_hl, link = false })
      local mode_hl_invert = invertHighlightGroup(mode_hl, mode_hl_colors)

      -- Apparently, my default Statusline highlight group colors -> guifg=#abb2bf guibg=#191a21
      vim.api.nvim_set_hl(0, 'MiniStatuslineDevinfo', { fg = '#ABB2BF', bg = '#191A21' })
      local dev_hl_colors = vim.api.nvim_get_hl(0, { name = 'MiniStatuslineDevinfo', link = false })
      local dev_hl_invert = invertHighlightGroup('MiniStatuslineDevinfo', dev_hl_colors)

      -- Setup fileinfo section colors
      if fileinfo_hl ~= nil then
        vim.api.nvim_set_hl(0, 'MiniStatuslineFileinfo', { fg = '#ABB2BF', bg = '#191A21' })
        local fileinfo_hl_colors = vim.api.nvim_get_hl(0, { name = fileinfo_hl, link = false })
        local mini_hl = vim.api.nvim_get_hl(0, { name = 'MiniStatuslineFileinfo', link = false })
        vim.api.nvim_set_hl(
          0,
          'MiniStatuslineFileinfo',
          { fg = fileinfo_hl_colors.fg, bg = mini_hl.bg }
        )
      end

      return combine_groups {
        { hl = mode_hl_invert, strings = { '' } },
        { hl = mode_hl, strings = { mode } },
        { hl = mode_hl_invert, strings = { '' } },
        ' ',
        { hl = dev_hl_invert, strings = { '' } },
        { hl = 'MiniStatuslineDevinfo', strings = { git, diff, diagnostics, lsp } },
        { hl = dev_hl_invert, strings = { '' } },
        '%<', -- Mark general truncate point
        ' ',
        { hl = 'MiniStatuslineFilename', strings = { filename } },
        '%=', -- End left alignment
        { hl = dev_hl_invert, strings = { '' } },
        { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
        { hl = dev_hl_invert, strings = { '' } },
        ' ',
        { hl = mode_hl_invert, strings = { '' } },
        { hl = mode_hl, strings = { search, location } },
        { hl = mode_hl_invert, strings = { '' } },
      }
    end

    -- Simple and easy statusline.
    --  You could remove this setup call if you don't like it,
    --  and try some other statusline plugin
    local statusline = require 'mini.statusline'
    -- set use_icons to true if you have a Nerd Font
    statusline.setup { content = { active = statuslineActive }, use_icons = true }

    -- Change the color of the division block by using its highlight group
    vim.api.nvim_set_hl(0, 'Statusline', { bg = 'bg' })

    -- NOTE: Start mini.comment configuration
    --
    -- Comment out lines using Ctrl-/ since I'm used to it from Jetbrains
    require('mini.comment').setup {
      mappings = {
        comment = '',
        comment_line = '<C-/>',
        comment_visual = '<C-/>',
        textobject = '<C-/>',
      },
    }

    -- NOTE: Start mini.starter configuration
    local days = {
      ['0'] = [[

███████╗██╗   ██╗███╗   ██╗██████╗  █████╗ ██╗   ██╗
██╔════╝██║   ██║████╗  ██║██╔══██╗██╔══██╗╚██╗ ██╔╝
███████╗██║   ██║██╔██╗ ██║██║  ██║███████║ ╚████╔╝ 
╚════██║██║   ██║██║╚██╗██║██║  ██║██╔══██║  ╚██╔╝  
███████║╚██████╔╝██║ ╚████║██████╔╝██║  ██║   ██║   
╚══════╝ ╚═════╝ ╚═╝  ╚═══╝╚═════╝ ╚═╝  ╚═╝   ╚═╝   
]],
      ['1'] = [[

███╗   ███╗ ██████╗ ███╗   ██╗██████╗  █████╗ ██╗   ██╗
████╗ ████║██╔═══██╗████╗  ██║██╔══██╗██╔══██╗╚██╗ ██╔╝
██╔████╔██║██║   ██║██╔██╗ ██║██║  ██║███████║ ╚████╔╝ 
██║╚██╔╝██║██║   ██║██║╚██╗██║██║  ██║██╔══██║  ╚██╔╝  
██║ ╚═╝ ██║╚██████╔╝██║ ╚████║██████╔╝██║  ██║   ██║   
╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═════╝ ╚═╝  ╚═╝   ╚═╝   
]],
      ['2'] = [[

████████╗██╗   ██╗███████╗███████╗██████╗  █████╗ ██╗   ██╗
╚══██╔══╝██║   ██║██╔════╝██╔════╝██╔══██╗██╔══██╗╚██╗ ██╔╝
   ██║   ██║   ██║█████╗  ███████╗██║  ██║███████║ ╚████╔╝ 
   ██║   ██║   ██║██╔══╝  ╚════██║██║  ██║██╔══██║  ╚██╔╝  
   ██║   ╚██████╔╝███████╗███████║██████╔╝██║  ██║   ██║   
   ╚═╝    ╚═════╝ ╚══════╝╚══════╝╚═════╝ ╚═╝  ╚═╝   ╚═╝   
]],
      ['3'] = [[

██╗    ██╗███████╗██████╗ ███╗   ██╗███████╗███████╗██████╗  █████╗ ██╗   ██╗
██║    ██║██╔════╝██╔══██╗████╗  ██║██╔════╝██╔════╝██╔══██╗██╔══██╗╚██╗ ██╔╝
██║ █╗ ██║█████╗  ██║  ██║██╔██╗ ██║█████╗  ███████╗██║  ██║███████║ ╚████╔╝ 
██║███╗██║██╔══╝  ██║  ██║██║╚██╗██║██╔══╝  ╚════██║██║  ██║██╔══██║  ╚██╔╝  
╚███╔███╔╝███████╗██████╔╝██║ ╚████║███████╗███████║██████╔╝██║  ██║   ██║   
 ╚══╝╚══╝ ╚══════╝╚═════╝ ╚═╝  ╚═══╝╚══════╝╚══════╝╚═════╝ ╚═╝  ╚═╝   ╚═╝   
]],
      ['4'] = [[

████████╗██╗  ██╗██╗   ██╗██████╗ ███████╗██████╗  █████╗ ██╗   ██╗
╚══██╔══╝██║  ██║██║   ██║██╔══██╗██╔════╝██╔══██╗██╔══██╗╚██╗ ██╔╝
   ██║   ███████║██║   ██║██████╔╝███████╗██║  ██║███████║ ╚████╔╝ 
   ██║   ██╔══██║██║   ██║██╔══██╗╚════██║██║  ██║██╔══██║  ╚██╔╝  
   ██║   ██║  ██║╚██████╔╝██║  ██║███████║██████╔╝██║  ██║   ██║   
   ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═════╝ ╚═╝  ╚═╝   ╚═╝   
]],
      ['5'] = [[

███████╗██████╗ ██╗██████╗  █████╗ ██╗   ██╗
██╔════╝██╔══██╗██║██╔══██╗██╔══██╗╚██╗ ██╔╝
█████╗  ██████╔╝██║██║  ██║███████║ ╚████╔╝ 
██╔══╝  ██╔══██╗██║██║  ██║██╔══██║  ╚██╔╝  
██║     ██║  ██║██║██████╔╝██║  ██║   ██║   
╚═╝     ╚═╝  ╚═╝╚═╝╚═════╝ ╚═╝  ╚═╝   ╚═╝   
]],
      ['6'] = [[

███████╗ █████╗ ████████╗██╗   ██╗██████╗ ██████╗  █████╗ ██╗   ██╗
██╔════╝██╔══██╗╚══██╔══╝██║   ██║██╔══██╗██╔══██╗██╔══██╗╚██╗ ██╔╝
███████╗███████║   ██║   ██║   ██║██████╔╝██║  ██║███████║ ╚████╔╝ 
╚════██║██╔══██║   ██║   ██║   ██║██╔══██╗██║  ██║██╔══██║  ╚██╔╝  
███████║██║  ██║   ██║   ╚██████╔╝██║  ██║██████╔╝██║  ██║   ██║   
╚══════╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝   ╚═╝   
]],
    }
    local footer = [[
██████╗ ██╗   ██╗████████╗      ██████╗ ███╗   ██╗
██╔══██╗██║   ██║╚══██╔══╝     ██╔═══██╗████╗  ██║
██║  ██║██║   ██║   ██║        ██║   ██║██╔██╗ ██║
██║  ██║╚██╗ ██╔╝   ██║        ██║   ██║██║╚██╗██║
██████╔╝ ╚████╔╝    ██║        ╚██████╔╝██║ ╚████║
╚═════╝   ╚═══╝     ╚═╝         ╚═════╝ ╚═╝  ╚═══╝
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
]]
    local starter = require 'mini.starter'
    starter.setup {
      header = days[os.date '%w'],
      footer = footer,
      items = {
        starter.sections.recent_files(10, false, false),
        starter.sections.telescope(),
        starter.sections.builtin_actions(),
      },
      content_hooks = {
        starter.gen_hook.adding_bullet '┃ ',
        starter.gen_hook.aligning('center', 'center'),
      },
    }

    -- NOTE: Start mini.jump configuration
    require('mini.jump').setup {
      delay = {
        highlight = -1,
      },
    }

    -- NOTE: Start mini.pairs configuration
    require('mini.pairs').setup {
      modes = {
        insert = true,
        command = true,
        terminal = false,
      },
    }

    -- NOTE: Start mini.files configuration
    local mini_files = require 'mini.files'
    mini_files.setup {
      mappings = {
        go_in = '',
        go_in_plus = '<right>',
        go_out = '<left>',
        go_out_plus = '',
        synchronize = '<CR>',
      },
      options = {
        permanent_delete = false,
      },
      windows = {
        max_number = 3,
      },
    }

    local mini_files_toggle = function()
      if not mini_files.close() then
        local current_file = vim.api.nvim_buf_get_name(0)
        -- Needed for starter dashboard
        if vim.fn.filereadable(current_file) == 0 then
          mini_files.open()
        else
          mini_files.open(current_file, true)
        end
      end
    end
    vim.keymap.set('n', '<leader>e', mini_files_toggle, { desc = 'Toggle [e]xplorer' })

    local map_split = function(buf_id, lhs, direction)
      local rhs = function()
        local get_entry = mini_files.get_fs_entry()

        -- Don't do anything if dealing with directory
        if get_entry == nil or get_entry.fs_type == 'directory' then
          return
        end

        -- Make new window
        local cur_target = mini_files.get_explorer_state().target_window
        local new_target = vim.api.nvim_win_call(cur_target, function()
          vim.cmd(direction .. ' split')
          return vim.api.nvim_get_current_win()
        end)

        pcall(vim.fn.win_execute, new_target, 'edit ' .. get_entry.path)
        mini_files.close()
        pcall(vim.api.nvim_set_current_win, new_target)
      end

      -- Adding `desc` will result into `show_help` entries
      local desc = 'Split ' .. direction
      vim.keymap.set('n', lhs, rhs, { buffer = buf_id, desc = desc })
    end

    local show_dotfiles = true

    local filter_show_all = function()
      return true
    end

    local filter_hide_dotfiles = function(fs_entry)
      return not vim.startswith(fs_entry.name, '.')
    end

    local toggle_dotfiles = function()
      show_dotfiles = not show_dotfiles
      local new_filter = show_dotfiles and filter_show_all or filter_hide_dotfiles
      MiniFiles.refresh { content = { filter = new_filter } }
    end

    vim.api.nvim_create_autocmd('User', {
      pattern = 'MiniFilesBufferCreate',
      callback = function(args)
        local buf_id = args.data.buf_id

        map_split(buf_id, '<C-h>', 'belowright horizontal')
        map_split(buf_id, '<C-v>', 'belowright vertical')

        vim.keymap.set(
          'n',
          '.',
          toggle_dotfiles,
          { buffer = buf_id, desc = 'Toggle hidden [.]files' }
        )

        vim.keymap.set(
          'n',
          '<ESC>',
          mini_files.close,
          { buffer = buf_id, desc = 'Close Mini Files' }
        )
        vim.keymap.set(
          'i',
          '<C-c>',
          mini_files.close,
          { buffer = buf_id, desc = 'Close Mini Files' }
        )
      end,
    })

    vim.api.nvim_create_autocmd('User', {
      pattern = 'MiniFilesWindowUpdate',
      callback = function(args)
        vim.wo[args.data.win_id].number = true
        vim.wo[args.data.win_id].relativenumber = true
      end,
    })

    -- NOTE: Start mini.indentscope configuration
    require('mini.indentscope').setup {
      draw = {
        delay = 0,
        animation = require('mini.indentscope').gen_animation.none(),
      },
      options = {
        indent_at_cursor = false,
        try_as_border = true,
      },
      symbol = '│',
    }
  end,
}
