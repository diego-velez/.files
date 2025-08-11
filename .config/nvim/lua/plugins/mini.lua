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
  --stylua: ignore
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
    { '<leader>/', function() MiniPick.registry.buf_lines() end, desc = '[/] Fuzzily search in current buffer', },
    { '<leader>so', function() MiniExtra.pickers.oldfiles() end, desc = '[S]earch [O]ld Files', },
    { '<leader>sr', function() MiniPick.builtin.resume() end, desc = '[S]earch [R]esume', },
    { '<leader>sg', function() MiniPick.builtin.grep_live() end, desc = '[S]earch [G]rep', },
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
    { '<leader>sf', function() MiniPick.registry.files() end, desc = '[S]earch [F]iles', }, -- See https://github.com/echasnovski/mini.nvim/discussions/1873
    { '<leader><space>', function() MiniPick.registry.files() end, desc = 'Search Files', },
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
        MiniPick.builtin.files(nil, {
          source = {
            cwd = vim.fn.stdpath 'config',
          },
        })
      end,
      desc = '[S]earch [C]onfig',
    },
    { '<leader>sh', function() MiniPick.builtin.help { default_split = 'vertical' } end, desc = '[S]earch [H]elp', },
    { '<leader>st', function() MiniPick.registry.todo() end, desc = '[S]earch [T]odo', },
    { '<leader>ss', function() MiniExtra.pickers.lsp { scope = 'document_symbol' } end, desc = '[S]earch [S]ymbols', },
    { '<leader>sH', function() MiniExtra.pickers.history() end, desc = '[S]earch [H]istory', },
    { '<leader>sd', function() MiniExtra.pickers.diagnostic() end, desc = '[S]earch [D]iagnostic', },
    { '<leader>sb', function() MiniPick.builtin.buffers() end, desc = '[S]earch [B]uffers', },
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
    { '<leader>sC', function() MiniExtra.pickers.colorschemes(nil, nil) end, desc = '[S]earch [C]olorscheme', },
  },
  config = function()
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
    local gen_ai_spec = MiniExtra.gen_ai_spec
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
    require 'plugins.mini.statusline'

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
    require 'plugins.mini.files'

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
    require 'plugins.mini.pick'

    -- NOTE: Start mini.clue configuration

    -- See MiniClue.gen_clues.z()
    local z_clues = function()
      return {
        { mode = 'n', keys = 'zA', desc = 'Toggle folds recursively' },
        { mode = 'n', keys = 'za', desc = 'Toggle fold' },
        { mode = 'n', keys = 'zb', desc = 'Redraw at bottom' },
        { mode = 'n', keys = 'zC', desc = 'Close folds recursively' },
        { mode = 'n', keys = 'zc', desc = 'Close fold' },
        { mode = 'n', keys = 'zD', desc = 'Delete folds recursively' },
        { mode = 'n', keys = 'zd', desc = 'Delete fold' },
        { mode = 'n', keys = 'zE', desc = 'Eliminate all folds' },
        { mode = 'n', keys = 'ze', desc = 'Scroll to cursor on right screen side' },
        { mode = 'n', keys = 'zF', desc = 'Create fold' },
        { mode = 'n', keys = 'zf', desc = 'Create fold (operator)' },
        { mode = 'n', keys = 'zG', desc = 'Temporarily mark as correctly spelled' },
        { mode = 'n', keys = 'zg', desc = 'Permanently mark as correctly spelled' },
        { mode = 'n', keys = 'zH', desc = 'Scroll left half screen' },
        { mode = 'n', keys = 'z<left>', desc = 'Scroll left', postkeys = 'z' },
        { mode = 'n', keys = 'zi', desc = "Toggle 'foldenable'" },
        { mode = 'n', keys = 'zj', desc = 'Move to start of next fold' },
        { mode = 'n', keys = 'zk', desc = 'Move to end of previous fold' },
        { mode = 'n', keys = 'zL', desc = 'Scroll right half screen' },
        { mode = 'n', keys = 'z<right>', desc = 'Scroll right', postkeys = 'z' },
        { mode = 'n', keys = 'zM', desc = 'Close all folds' },
        { mode = 'n', keys = 'zm', desc = 'Fold more' },
        { mode = 'n', keys = 'zN', desc = "Set 'foldenable'" },
        { mode = 'n', keys = 'zn', desc = "Reset 'foldenable'" },
        { mode = 'n', keys = 'zO', desc = 'Open folds recursively' },
        { mode = 'n', keys = 'zo', desc = 'Open fold' },
        { mode = 'n', keys = 'zP', desc = 'Paste without trailspace' },
        { mode = 'n', keys = 'zp', desc = 'Paste without trailspace' },
        { mode = 'n', keys = 'zR', desc = 'Open all folds' },
        { mode = 'n', keys = 'zr', desc = 'Fold less' },
        { mode = 'n', keys = 'zs', desc = 'Scroll to cursor on left screen side' },
        { mode = 'n', keys = 'zt', desc = 'Redraw at top' },
        { mode = 'n', keys = 'zu', desc = '+Undo spelling commands' },
        { mode = 'n', keys = 'zug', desc = 'Undo `zg`' },
        { mode = 'n', keys = 'zuG', desc = 'Undo `zG`' },
        { mode = 'n', keys = 'zuw', desc = 'Undo `zw`' },
        { mode = 'n', keys = 'zuW', desc = 'Undo `zW`' },
        { mode = 'n', keys = 'zv', desc = 'Open enough folds' },
        { mode = 'n', keys = 'zW', desc = 'Temporarily mark as incorrectly spelled' },
        { mode = 'n', keys = 'zw', desc = 'Permanently mark as incorrectly spelled' },
        { mode = 'n', keys = 'zX', desc = 'Update folds' },
        { mode = 'n', keys = 'zx', desc = 'Update folds + open enough folds' },
        { mode = 'n', keys = 'zy', desc = 'Yank without trailing spaces (operator)' },
        { mode = 'n', keys = 'zz', desc = 'Redraw at center' },
        { mode = 'n', keys = 'z+', desc = 'Redraw under bottom at top' },
        { mode = 'n', keys = 'z-', desc = 'Redraw at bottom + cursor on first non-blank' },
        { mode = 'n', keys = 'z.', desc = 'Redraw at center + cursor on first non-blank' },
        { mode = 'n', keys = 'z=', desc = 'Show spelling suggestions' },
        { mode = 'n', keys = 'z^', desc = 'Redraw above top at bottom' },

        { mode = 'x', keys = 'zf', desc = 'Create fold from selection' },
      }
    end

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
        vim.tbl_extend('force', miniclue.gen_clues.windows { submode_resize = true }, {
          { mode = 'n', keys = '<C-w><left>', desc = 'Focus left', postkeys = '<C-w>' },
          { mode = 'n', keys = '<C-w><right>', desc = 'Focus right', postkeys = '<C-w>' },
          { mode = 'n', keys = '<C-w><up>', desc = 'Focus top', postkeys = '<C-w>' },
          { mode = 'n', keys = '<C-w><down>', desc = 'Focus bottom', postkeys = '<C-w>' },
        }),
        z_clues(),
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
    local lspRefTextHl = vim.api.nvim_get_hl(0, { name = 'LspReferenceText', link = false })
    vim.api.nvim_set_hl(
      0,
      'MiniCursorword',
      { fg = lspRefTextHl.fg, bg = lspRefTextHl.bg, underline = true }
    )

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

    vim.api.nvim_create_autocmd('FileType', {
      desc = 'Disable mini.animate for Grug-Far',
      pattern = 'grug-far',
      callback = function()
        vim.b.minianimate_disable = true
      end,
    })

    local animate = require 'mini.animate'
    animate.setup {
      cursor = {
        enable = false,
      },
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

    -- NOTE: Start mini.bracketed configuration
    require('mini.bracketed').setup {
      buffer = { suffix = '', options = {} },
      comment = { suffix = '', options = {} },
      conflict = { suffix = '', options = {} },
      diagnostic = { suffix = '', options = {} },
      file = { suffix = 'f', options = {} },
      indent = { suffix = '', options = {} },
      jump = { suffix = 'j', options = {} },
      location = { suffix = '', options = {} },
      oldfile = { suffix = 'o', options = {} },
      quickfix = { suffix = '', options = {} },
      treesitter = { suffix = '', options = {} },
      undo = { suffix = '', options = {} },
      window = { suffix = '', options = {} },
      yank = { suffix = '', options = {} },
    }

    -- NOTE: Start mini.snippets configuration
    local gen_loader = require('mini.snippets').gen_loader
    require('mini.snippets').setup {
      snippets = {
        -- Load custom file with global snippets first (adjust for Windows)
        gen_loader.from_file '~/.config/nvim/snippets/global.json',

        -- Load snippets based on current language by reading files from
        -- "snippets/" subdirectories from 'runtimepath' directories.
        gen_loader.from_lang(),
      },
      mappings = {
        -- Expand snippet at cursor position. Created globally in Insert mode.
        expand = '',

        -- Interact with default `expand.insert` session.
        -- Created for the duration of active session(s)
        jump_next = '',
        jump_prev = '',
        stop = '',
      },
      expand = {
        match = function(snips)
          return require('mini.snippets').default_match(snips, { pattern_fuzzy = '%S+' })
        end,
      },
    }
  end,
}
