return { -- Collection of various small independent plugins/modules
  'echasnovski/mini.nvim',
  lazy = false,
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
    {
      '<leader>/',
      function()
        require('mini.pick').registry.buf_lines { scope = 'current' }
      end,
      desc = '[/] Fuzzily search in current buffer',
    },
    {
      '<leader>so',
      function()
        require('mini.extra').pickers.oldfiles()
      end,
      desc = '[S]earch [O]ld Files',
    },
    {
      '<leader>sr',
      function()
        require('mini.pick').builtin.resume()
      end,
      desc = '[S]earch [R]esume',
    },
    {
      '<leader>sg',
      function()
        require('mini.pick').builtin.grep_live()
      end,
      desc = '[S]earch [G]rep',
    },
    {
      '<leader>sf',
      function()
        require('mini.pick').builtin.files()
      end,
      desc = '[S]earch [F]iles',
    },
    {
      '<leader>sk',
      function()
        require('mini.extra').pickers.keymaps()
      end,
      desc = '[S]earch [K]eymaps',
    },
    {
      '<leader>sh',
      function()
        require('mini.pick').builtin.help { default_split = 'vertical' }
      end,
      desc = '[S]earch [H]elp',
    },
    {
      '<leader>st',
      function()
        require('mini.pick').registry.todo()
      end,
      desc = '[S]earch [T]odo',
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

      -- Setup filename section colors
      vim.api.nvim_set_hl(0, 'MiniStatuslineFilename', { fg = 'fg', bg = 'bg' })

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
    local mini_pick = {
      { name = 'Browser', action = require('mini.files').open, section = 'Mini' },
      { name = 'Files', action = 'Pick files', section = 'Mini' },
      { name = 'Help', action = 'Pick help', section = 'Mini' },
      { name = 'Grep', action = 'Pick grep_live', section = 'Mini' },
      { name = 'Old Files', action = require('mini.extra').pickers.oldfiles, section = 'Mini' },
    }
    local starter = require 'mini.starter'
    starter.setup {
      header = days[os.date '%w'],
      footer = footer,
      items = {
        starter.sections.recent_files(10, false, false),
        mini_pick,
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

    -- NOTE: Start mini.git configuration
    require('mini.git').setup()

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

    -- Use to try and automatically detect
    vim.api.nvim_create_autocmd('User', {
      pattern = { 'MiniFilesActionRename', 'MiniFilesActionMove' },
      callback = function(args)
        local from = args.data.from
        local to = args.data.to

        pcall(vim.cmd, 'Git add ' .. from .. ' ' .. to)
      end,
    })

    -- NOTE: Start mini.indentscope configuration
    require('mini.indentscope').setup {
      options = {
        indent_at_cursor = false,
        try_as_border = true,
      },
      symbol = '│',
    }

    -- NOTE: Start mini.pick configuration with mini.extra pickers
    require('mini.extra').setup()
    require('mini.pick').setup {
      delay = {
        busy = 1,
      },

      mappings = {
        caret_left = '<Left>',
        caret_right = '<Right>',

        choose = '<CR>',
        choose_in_split = '<C-h>',
        choose_in_vsplit = '<C-v>',
        choose_in_tabpage = '<C-t>',
        choose_marked = '<C-CR>',

        delete_char = '<BS>',
        delete_char_right = '<Del>',
        delete_left = '',
        delete_word = '',

        mark = '',
        mark_all = '<C-a>',

        move_down = '<Down>',
        move_start = '<C-g>',
        move_up = '<Up>',

        paste = '<C-p>',

        scroll_down = '<C-d>',
        scroll_left = '<C-Left>',
        scroll_right = '<C-Right>',
        scroll_up = '<C-u>',

        stop = '<Esc>',

        toggle_info = '<Tab>',
        toggle_preview = '',

        send_to_quickfix = {
          char = '<C-q>',
          func = function()
            local mappings = MiniPick.get_picker_opts().mappings
            vim.api.nvim_input(mappings.mark_all .. mappings.choose_marked)
          end,
        },
      },

      options = {
        use_cache = true,
      },

      window = {
        config = function()
          local height = math.floor(0.618 * vim.o.lines)
          local width = math.floor(0.618 * vim.o.columns)
          return {
            anchor = 'NW',
            height = height,
            width = width,
            row = math.floor(0.5 * (vim.o.lines - height)),
            col = math.floor(0.5 * (vim.o.columns - width)),
          }
        end,
        prompt_prefix = '󰁔 ',
        prompt_cursor = ' 󰁍',
      },
    }

    -- Setup mini.pick highlight groups
    local dracula = require('dracula').colors()
    vim.api.nvim_set_hl(0, 'MiniPickBorder', { fg = dracula.purple, bg = 'bg' })
    vim.api.nvim_set_hl(0, 'MiniPickBorderText', { fg = 'fg', bg = 'bg' })
    vim.api.nvim_set_hl(0, 'MiniPickPrompt', { fg = dracula.purple, bg = 'bg' })
    vim.api.nvim_set_hl(0, 'MiniPickMatchRanges', { fg = dracula.green, bg = 'bg' })

    -- Show highlight in buf_lines picker
    -- See https://github.com/echasnovski/mini.nvim/discussions/988#discussioncomment-10398788
    local ns_digit_prefix = vim.api.nvim_create_namespace 'cur-buf-pick-show'
    local show_cur_buf_lines = function(buf_id, items, query, opts)
      if items == nil or #items == 0 then
        return
      end

      -- Show as usual
      MiniPick.default_show(buf_id, items, query, opts)

      -- Move prefix line numbers into inline extmarks
      local lines = vim.api.nvim_buf_get_lines(buf_id, 0, -1, false)
      local digit_prefixes = {}
      for i, l in ipairs(lines) do
        local _, prefix_end, prefix = l:find '^(%s*%d+│)'
        if prefix_end ~= nil then
          digit_prefixes[i], lines[i] = prefix, l:sub(prefix_end + 1)
        end
      end

      vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
      for i, pref in pairs(digit_prefixes) do
        local opts = { virt_text = { { pref, 'MiniPickNormal' } }, virt_text_pos = 'inline' }
        vim.api.nvim_buf_set_extmark(buf_id, ns_digit_prefix, i - 1, 0, opts)
      end

      -- Set highlighting based on the curent filetype
      local ft = vim.bo[items[1].bufnr].filetype
      local has_lang, lang = pcall(vim.treesitter.language.get_lang, ft)
      local has_ts, _ = pcall(vim.treesitter.start, buf_id, has_lang and lang or ft)
      if not has_ts and ft then
        vim.bo[buf_id].syntax = ft
      end
    end

    MiniPick.registry.buf_lines = function()
      local local_opts = { scope = 'current', preserve_order = true } -- use preserve_order
      -- local local_opts = { scope = 'current' }
      MiniExtra.pickers.buf_lines(local_opts, { source = { show = show_cur_buf_lines } })
    end

    MiniPick.registry.todo = function()
      local show_todo = function(buf_id, entries, query, opts)
        MiniPick.default_show(buf_id, entries, query, opts)

        -- Add highlighting to every line in the buffer
        for line, entry in ipairs(entries) do
          for _, hl in ipairs(entry.hl) do
            vim.api.nvim_buf_add_highlight(
              buf_id,
              ns_digit_prefix,
              hl[2],
              line - 1,
              hl[1][1],
              hl[1][2]
            )
          end
        end
      end
      require('todo-comments.search').search(function(results)
        local Config = require 'todo-comments.config'
        local Highlight = require 'todo-comments.highlight'

        for i, entry in ipairs(results) do
          -- By default, mini.pick uses the path item when an item is choosen to open it
          entry.path = entry.filename
          entry.filename = nil

          local relative_path = string.gsub(entry.path, vim.fn.getcwd() .. '/', '')
          local display = string.format('%s:%s:%s ', relative_path, entry.lnum, entry.col)
          local text = entry.text
          local start, finish, kw = Highlight.match(text)

          entry.hl = {}

          if start then
            kw = Config.keywords[kw] or kw
            local icon = Config.options.keywords[kw].icon or ' '
            display = icon .. ' ' .. display
            table.insert(entry.hl, { { 0, #icon + 1 }, 'TodoFg' .. kw })
            text = vim.trim(text:sub(start))

            table.insert(entry.hl, {
              { #display, #display + finish - start + 2 },
              'TodoBg' .. kw,
            })
            table.insert(entry.hl, {
              { #display + finish - start + 1, #display + finish + 1 + #text },
              'TodoFg' .. kw,
            })
            entry.text = display .. ' ' .. text
          end

          results[i] = entry
        end

        MiniPick.start { source = { name = 'Find Todo', show = show_todo, items = results } }
      end, nil)
    end

    -- Open LSP picker for the given scope
    ---@param scope "declaration" | "definition" | "document_symbol" | "implementation" | "references" | "type_definition" | "workspace_symbol"
    ---@param autojump boolean? If there is only one result it will jump to it.
    function MiniPick.LspPicker(scope, autojump)
      ---@return string
      local function get_symbol_query()
        return vim.fn.input 'Symbol: '
      end

      if not autojump then
        local opts = { scope = scope }

        if scope == 'workspace_symbol' then
          opts.symbol_query = get_symbol_query()
        end

        require('mini.extra').pickers.lsp(opts)
        return
      end

      ---@param opts vim.lsp.LocationOpts.OnList
      local function on_list(opts)
        vim.fn.setqflist({}, ' ', opts)

        if #opts.items == 1 then
          vim.cmd.cfirst()
        else
          require('mini.extra').pickers.list({ scope = 'quickfix' }, {
            source = { name = opts.title },
            window = {
              config = function()
                local height = math.floor(0.618 * vim.o.lines)
                local width = math.floor(0.618 * vim.o.columns)
                return {
                  relative = 'cursor',
                  anchor = 'NW',
                  height = height,
                  width = width,
                  row = 0,
                  col = 0,
                }
              end,
            },
          })
        end
      end

      if scope == 'references' then
        vim.lsp.buf.references(nil, { on_list = on_list })
        return
      end

      if scope == 'workspace_symbol' then
        vim.lsp.buf.workspace_symbol(get_symbol_query(), { on_list = on_list })
        return
      end

      vim.lsp.buf[scope] { on_list = on_list }
    end
  end,
}
