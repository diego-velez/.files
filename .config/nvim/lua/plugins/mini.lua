-- Use proper slash depending on OS
local parent_dir_pattern = vim.fn.has 'win32' == 1 and '([^\\/]+)([\\/])' or '([^/]+)(/)'

-- Shorten a folder's name
local shorten_dirname = function(name, path_sep)
  local first = vim.fn.strcharpart(name, 0, 1)
  first = first == '.' and vim.fn.strcharpart(name, 0, 2) or first
  return first .. path_sep
end

-- Shorten one path
-- WARN: This can only be called for MiniPick
local make_short_path = function(path)
  local win_id = MiniPick.get_picker_state().windows.main
  local buf_width = vim.api.nvim_win_get_width(win_id)
  local char_count = vim.fn.strchars(path)
  -- Do not shorten the path if it is not needed
  if char_count < buf_width then
    return path
  end

  local shortened_path = path:gsub(parent_dir_pattern, shorten_dirname)
  char_count = vim.fn.strchars(shortened_path)
  -- Return only the filename when the shorten path still overflows
  if char_count >= buf_width then
    return shortened_path:match(parent_dir_pattern)
  end

  return shortened_path
end

return { -- Collection of various small independent plugins/modules
  'echasnovski/mini.nvim',
  lazy = false,
  dependencies = {
    'nvim-treesitter/nvim-treesitter-textobjects',
    {
      'JoosepAlviste/nvim-ts-context-commentstring',
      lazy = true,
      opts = {
        enable_autocmd = false,
      },
    },
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
        MiniHipatterns.toggle(0)
        vim.g.highlighting_enabled = not vim.g.highlighting_enabled

        if vim.g.highlighting_enabled then
          vim.notify('Highlighting enabled', vim.log.levels.INFO)
        else
          vim.notify('Highlighting disabled', vim.log.levels.INFO)
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
      '<leader>sG',
      function()
        vim.ui.input({
          prompt = 'What directory do you want to search in? ',
          default = vim.uv.cwd(),
          completion = 'dir',
        }, function(input)
          if not input or input == '' then
            return
          end

          MiniPick.builtin.grep_live({}, { source = { cwd = input } })
        end)
      end,
      desc = '[S]earch [G]rep in specific directory',
    },
    {
      '<leader>sw',
      function()
        local cword = vim.fn.expand '<cword>'
        vim.defer_fn(function()
          MiniPick.set_picker_query { cword }
        end, 25)
        MiniPick.builtin.grep_live()
      end,
      desc = '[S]earch [W]ord',
    },
    {
      '<leader>sf',
      -- See https://github.com/echasnovski/mini.nvim/discussions/1873
      function()
        MiniPick.registry.files()
      end,
      desc = '[S]earch [F]iles',
    },
    {
      '<leader>sF',
      function()
        vim.ui.input({
          prompt = 'What directory do you want to search in? ',
          default = vim.uv.cwd(),
          completion = 'dir',
        }, function(input)
          if not input or input == '' then
            return
          end

          MiniPick.registry.files({}, { source = { cwd = input } })
        end)
      end,
      desc = '[S]earch [F]iles in specific directory',
    },
    {
      '<leader>sc',
      function()
        require('mini.pick').builtin.files(nil, {
          source = {
            cwd = vim.fn.stdpath 'config',
          },
        })
      end,
      desc = '[S]earch [C]onfig',
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
    {
      '<leader>ss',
      function()
        MiniExtra.pickers.lsp { scope = 'document_symbol' }
      end,
      desc = '[S]earch [S]ymbols',
    },
    {
      '<leader>sH',
      function()
        MiniExtra.pickers.history()
      end,
      desc = '[S]earch [H]istory',
    },
    {
      '<leader>sd',
      function()
        MiniExtra.pickers.diagnostic()
      end,
      desc = '[S]earch [D]iagnostic',
    },
    {
      '<leader>sb',
      function()
        MiniPick.builtin.buffers()
      end,
      desc = '[S]earch [B]uffers',
    },
    {
      '<leader>n',
      function()
        MiniNotify.show_history()

        local buf_id
        for _, id in ipairs(vim.api.nvim_list_bufs()) do
          if vim.bo[id].filetype == 'mininotify-history' then
            buf_id = id
          end
        end
        if buf_id == nil then
          return
        end

        -- idk how else to exit than by deleting it lmao
        -- :q from this buffer just exits Neovim for some reason
        local exit_buffer = function()
          MiniBufremove.delete(buf_id, true)
        end

        vim.keymap.set('n', '<ESC>', exit_buffer, { buffer = buf_id })
        vim.keymap.set('n', 'q', exit_buffer, { buffer = buf_id })
      end,
      desc = '[N]otification History',
    },
  },
  config = function()
    local dracula = require('dracula').colors()

    -- NOTE: Start mini.icons configuration
    require('mini.icons').setup()

    -- NOTE: Start mini.git configuration
    require('mini.git').setup()

    -- NOTE: Start mini.extra configuration
    require('mini.extra').setup()

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
    local gen_ai_spec = require('mini.extra').gen_ai_spec
    ai.setup {
      n_lines = 500,
      custom_textobjects = {
        -- Code Block
        o = ai.gen_spec.treesitter {
          a = { '@block.outer', '@conditional.outer', '@loop.outer' },
          i = { '@block.inner', '@conditional.inner', '@loop.inner' },
        },

        -- [C]lass
        c = ai.gen_spec.treesitter { a = '@class.outer', i = '@class.inner' },

        -- [F]unction
        f = ai.gen_spec.treesitter { a = '@function.outer', i = '@function.inner' },

        -- [B]uffer
        b = gen_ai_spec.buffer(),

        -- [U]sage
        u = ai.gen_spec.function_call(),

        -- [D]igits
        d = gen_ai_spec.number(),
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

      local fileinfo, icon_hl = section_fileinfo { trunc_width = 75 }
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

      -- Setup devinfo and fileinfo section colors
      local dev_hl_invert = ''
      if icon_hl ~= nil then
        local icon_hl_colors = vim.api.nvim_get_hl(0, { name = icon_hl, link = false })
        vim.api.nvim_set_hl(
          0,
          'MiniStatuslineFileinfo',
          { fg = icon_hl_colors.fg, bg = dracula.menu }
        )

        vim.api.nvim_set_hl(
          0,
          'MiniStatuslineDevinfo',
          { fg = icon_hl_colors.fg, bg = dracula.menu }
        )
        local dev_hl_colors =
          vim.api.nvim_get_hl(0, { name = 'MiniStatuslineDevinfo', link = false })
        dev_hl_invert = invertHighlightGroup('MiniStatuslineDevinfo', dev_hl_colors)
      else
        vim.api.nvim_set_hl(0, 'MiniStatuslineDevinfo', { fg = dracula.white, bg = dracula.menu })
        local dev_hl_colors =
          vim.api.nvim_get_hl(0, { name = 'MiniStatuslineDevinfo', link = false })
        dev_hl_invert = invertHighlightGroup('MiniStatuslineDevinfo', dev_hl_colors)
        vim.api.nvim_set_hl(0, 'MiniStatuslineFileinfo', { fg = dracula.white, bg = dracula.menu })
      end

      -- Setup filename section colors
      vim.api.nvim_set_hl(0, 'MiniStatuslineFilename', { fg = dracula.white, bg = 'bg' })

      -- Do not show rounded corners for the dev section
      local devLeftOuter, devRightOuter = '', ''
      if #git + #diff + #diagnostics + #lsp == 0 then
        devLeftOuter, devRightOuter = '', ''
      end

      return combine_groups {
        { hl = mode_hl_invert, strings = { '' } },
        { hl = mode_hl, strings = { mode } },
        { hl = mode_hl_invert, strings = { '' } },
        ' ',
        { hl = dev_hl_invert, strings = { devLeftOuter } },
        { hl = 'MiniStatuslineDevinfo', strings = { git, diff, diagnostics, lsp } },
        { hl = dev_hl_invert, strings = { devRightOuter } },
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
    require('mini.comment').setup {
      options = {
        custom_commentstring = function()
          return require('ts_context_commentstring.internal').calculate_commentstring()
            or vim.bo.commentstring
        end,
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
      -- skip autopair when next character is one of these
      skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
      -- skip autopair when the cursor is inside these treesitter nodes
      skip_ts = { 'string' },
      -- skip autopair when next character is closing pair
      -- and there are more closing pairs than opening pairs
      skip_unbalanced = true,
      -- better deal with markdown code blocks
      markdown = true,
    }

    -- NOTE: Start mini.files configuration
    local mini_files = require 'mini.files'
    mini_files.setup {
      mappings = {
        close = 'q',
        go_in = '',
        go_in_plus = '',
        go_out = '<C-e>',
        go_out_plus = '',
        mark_set = 'm',
        mark_goto = "'",
        reset = '<BS>',
        reveal_cwd = '@',
        show_help = '?',
        synchronize = '<CR>',
        trim_left = '<',
        trim_right = '>',
      },
      options = {
        permanent_delete = false,
      },
      windows = {
        max_number = 3,
      },
    }

    -- Auto-expand empty & nested dirs
    -- See https://github.com/echasnovski/mini.nvim/discussions/1184
    local expand_single_dir
    expand_single_dir = vim.schedule_wrap(function()
      local is_one_dir = vim.api.nvim_buf_line_count(0) == 1
        and (MiniFiles.get_fs_entry() or {}).fs_type == 'directory'
      if not is_one_dir then
        return
      end
      MiniFiles.go_in { close_on_file = true }
      expand_single_dir()
    end)

    local go_in_and_expand = function()
      local fs_entry = MiniFiles.get_fs_entry()
      local should_expand = fs_entry ~= nil and fs_entry.fs_type == 'file'

      MiniFiles.go_in { close_on_file = true }

      -- Need to check otherwise it will throw error because the mini.files window was closed
      if not should_expand then
        expand_single_dir()
      end
    end

    vim.api.nvim_create_autocmd('User', {
      pattern = 'MiniFilesBufferCreate',
      callback = function(args)
        vim.keymap.set('n', '<C-y>', go_in_and_expand, { buffer = args.data.buf_id })
        vim.keymap.set('n', '<C-p>', '<up>', { buffer = args.data.buf_id })
        vim.keymap.set('n', '<C-n>', '<down>', { buffer = args.data.buf_id })
      end,
    })

    --- @param open_current_file boolean If true, will open mini.files in the current file, otherwise opents on cwd.
    local mini_files_toggle = function(open_current_file)
      if not mini_files.close() then
        local current_file = vim.api.nvim_buf_get_name(0)
        -- Needed for starter dashboard
        if vim.fn.filereadable(current_file) == 0 or not open_current_file then
          mini_files.open()
        else
          mini_files.open(current_file, true)
        end
      end
    end
    vim.keymap.set('n', '<leader>e', function()
      mini_files_toggle(true)
    end, { desc = 'Toggle [e]xplorer on current file' })
    vim.keymap.set('n', '<leader>E', function()
      mini_files_toggle(false)
    end, { desc = 'Toggle [E]xplorer on cwd' })

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
      group = vim.api.nvim_create_augroup('DVT MiniFilesBufferCreate', { clear = true }),
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
      group = vim.api.nvim_create_augroup('DVT MiniFilesWindowUpdate', { clear = true }),
      pattern = 'MiniFilesWindowUpdate',
      callback = function(args)
        vim.wo[args.data.win_id].number = true
        vim.wo[args.data.win_id].relativenumber = true
      end,
    })

    -- Use to try and automatically detect
    vim.api.nvim_create_autocmd('User', {
      group = vim.api.nvim_create_augroup(
        'DVT MiniFilesAction Git/LSP integration',
        { clear = true }
      ),
      pattern = { 'MiniFilesActionRename', 'MiniFilesActionMove' },
      callback = function(args)
        local from = args.data.from
        local to = args.data.to
        local lsp_changes = {
          files = {
            {
              oldUri = vim.uri_from_fname(from),
              newUri = vim.uri_from_fname(to),
            },
          },
        }

        -- LSP integation
        -- See https://github.com/folke/snacks.nvim/blob/bc0630e43be5699bb94dadc302c0d21615421d93/lua/snacks/rename.lua#L85
        local clients = vim.lsp.get_clients()
        for _, client in ipairs(clients) do
          local lsp_rename_files_method = vim.lsp.protocol.Methods.workspace_willRenameFiles
          if client:supports_method(lsp_rename_files_method) then
            local resp = client:request_sync(lsp_rename_files_method, lsp_changes, 1000, 0)
            if resp and resp.result ~= nil then
              vim.lsp.util.apply_workspace_edit(resp.result, client.offset_encoding)
            end
          end
        end

        for _, client in ipairs(clients) do
          local lsp_rename_files_method = vim.lsp.protocol.Methods.workspace_didRenameFiles
          if client:supports_method(lsp_rename_files_method) then
            client:notify(lsp_rename_files_method, lsp_changes)
          end
        end

        -- Auto file to Git in order for it to detect file was renamed or moved
        -- We check because if the git add command runs it'll notify the error
        local is_inside_git_repo = vim
          .system({
            'git',
            'rev-parse',
            '--is-inside-work-tree',
          }, { text = true })
          :wait()
        if is_inside_git_repo.code ~= 0 then
          return
        end

        pcall(vim.cmd, 'Git add ' .. from .. ' ' .. to)
      end,
    })

    -- NOTE: Start mini.indentscope configuration
    require('mini.indentscope').setup {
      draw = {
        animation = require('mini.indentscope').gen_animation.cubic { duration = 10 },
      },
      options = {
        indent_at_cursor = false,
        try_as_border = true,
      },
      symbol = '│',
    }

    -- NOTE: Start mini.pick configuration
    require('mini.pick').setup {
      delay = {
        busy = 1,
      },

      mappings = {
        caret_left = '<Left>',
        caret_right = '<Right>',

        choose = '<C-y>',
        choose_in_split = '<C-h>',
        choose_in_vsplit = '<C-v>',
        choose_in_tabpage = '<C-t>',
        choose_marked = '<C-q>',

        delete_char = '<BS>',
        delete_char_right = '<Del>',
        delete_left = '<C-u>',
        delete_word = '<C-w>',

        mark = '<C-x>',
        mark_all = '<C-a>',

        move_down = '<C-n>',
        move_start = '<C-g>',
        move_up = '<C-p>',

        paste = '',

        refine = '<C-CR>',
        refine_marked = '',

        scroll_down = '<C-f>',
        scroll_left = '<C-Left>',
        scroll_right = '<C-Right>',
        scroll_up = '<C-b>',

        stop = '<Esc>',

        toggle_info = '<S-Tab>',
        toggle_preview = '<Tab>',

        another_choose = {
          char = '<CR>',
          func = function()
            local choose_mapping = MiniPick.get_picker_opts().mappings.choose
            vim.api.nvim_input(choose_mapping)
          end,
        },
        actual_paste = {
          char = '<C-r>',
          func = function()
            local content = vim.fn.getreg '+'
            if content ~= '' then
              local current_query = MiniPick.get_picker_query() or {}
              table.insert(current_query, content)
              MiniPick.set_picker_query(current_query)
            end
          end,
        },
      },

      options = {
        use_cache = false,
      },

      window = {
        prompt_prefix = '󰁔 ',
        prompt_caret = ' ',
      },
    }

    -- Using primarily for code action
    -- See https://github.com/echasnovski/mini.nvim/discussions/1437
    vim.ui.select = MiniPick.ui_select

    -- Shorten file paths by default
    local show_short_files = function(buf_id, items_to_show, query)
      local short_items_to_show = vim.tbl_map(make_short_path, items_to_show)
      -- TODO: Instead of using default show, replace in order to highlight proper folder and add icons back
      MiniPick.default_show(buf_id, short_items_to_show, query)
    end

    MiniPick.registry.files = function(local_opts, opts)
      opts = opts or {
        source = { show = show_short_files },
      }
      MiniPick.builtin.files(local_opts, opts)
    end

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
      -- local local_opts = { scope = 'current', preserve_order = true } -- use preserve_order
      local local_opts = { scope = 'current' }
      MiniExtra.pickers.buf_lines(local_opts, { source = { show = show_cur_buf_lines } })
    end

    -- todo-comments picker section
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

    MiniPick.registry.todo = function()
      require('todo-comments.search').search(function(results)
        -- Don't do anything if there are no todos in the project
        if #results == 0 then
          return
        end

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
            display = icon .. display
            table.insert(entry.hl, { { 0, #icon }, 'TodoFg' .. kw })
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
      end)
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

    -- NOTE: Start mini.clue configuration
    local miniclue = require 'mini.clue'
    miniclue.setup {
      triggers = {
        -- Leader triggers
        { mode = 'n', keys = '<Leader>' },
        { mode = 'x', keys = '<Leader>' },

        -- Built-in completion
        { mode = 'i', keys = '<C-x>' },

        -- `g` key
        { mode = 'n', keys = 'g' },
        { mode = 'x', keys = 'g' },

        -- Marks
        { mode = 'n', keys = "'" },
        { mode = 'n', keys = '`' },
        { mode = 'x', keys = "'" },
        { mode = 'x', keys = '`' },

        -- Registers
        { mode = 'n', keys = '"' },
        { mode = 'x', keys = '"' },
        { mode = 'i', keys = '<C-r>' },
        { mode = 'c', keys = '<C-r>' },

        -- Window commands
        { mode = 'n', keys = '<C-w>' },

        -- `z` key
        { mode = 'n', keys = 'z' },
        { mode = 'x', keys = 'z' },

        -- Tabs
        { mode = 'n', keys = '<tab>' },

        -- Brackets
        { mode = 'n', keys = '[' },
        { mode = 'n', keys = ']' },
      },

      clues = {
        {
          { mode = 'n', keys = '<leader>s', desc = '[S]earch' },
          { mode = 'n', keys = '<leader>t', desc = '[T]oggle' },
          { mode = 'n', keys = '<leader>l', desc = '[L]ist' },
          { mode = 'n', keys = '<leader>u', desc = '[U]I' },
          { mode = 'n', keys = '<leader>c', desc = '[C]ode' },
          { mode = 'n', keys = '<leader>g', desc = '[G]it' },
          { mode = 'x', keys = '<leader>g', desc = '[G]it' },
          { mode = 'n', keys = '<leader><tab>', desc = '[T]ab' },
        },
        miniclue.gen_clues.builtin_completion(),
        miniclue.gen_clues.g(),
        miniclue.gen_clues.marks(),
        miniclue.gen_clues.registers(),
        miniclue.gen_clues.windows(),
        miniclue.gen_clues.z(),
      },

      window = {
        config = {
          width = 50,
        },
        delay = 0,
      },
    }

    -- NOTE: Start mini.cursorword configuration
    require('mini.cursorword').setup()

    -- NOTE: Start mini.animate configuration
    --
    -- don't use animate when scrolling with the mouse
    local mouse_scrolled = false
    for _, scroll in ipairs { 'Up', 'Down' } do
      local key = '<ScrollWheel' .. scroll .. '>'
      vim.keymap.set({ '', 'i' }, key, function()
        mouse_scrolled = true
        return key
      end, { expr = true })
    end

    local animate = require 'mini.animate'
    animate.setup {
      resize = {
        timing = animate.gen_timing.linear { duration = 50, unit = 'total' },
      },
      scroll = {
        timing = animate.gen_timing.linear { duration = 150, unit = 'total' },
        subscroll = animate.gen_subscroll.equal {
          predicate = function(total_scroll)
            if mouse_scrolled then
              mouse_scrolled = false
              return false
            end
            return total_scroll > 1
          end,
        },
      },
    }

    -- NOTE: Start mini.notify configuration
    require('mini.notify').setup {
      content = {
        -- Add notifications to the bottom
        sort = function(notif_arr)
          table.sort(notif_arr, function(a, b)
            return a.ts_update < b.ts_update
          end)
          return notif_arr
        end,
      },
      window = {
        winblend = 0,
      },
    }
    vim.notify = MiniNotify.make_notify()

    -- NOTE: Start mini.splitjoin configuration
    require('mini.splitjoin').setup()

    -- NOTE: Start mini.trailspace configuration
    require('mini.trailspace').setup()

    -- NOTE: Start mini.bufremove configuration
    require('mini.bufremove').setup()
  end,
}
