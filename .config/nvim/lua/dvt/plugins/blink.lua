return {
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    dependencies = {
      { 'justinsgithub/wezterm-types', lazy = true },
    },
    ft = 'lua',
    cmd = 'LazyDev',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
        { path = 'wezterm-types', mods = { 'wezterm' } },
      },
    },
  },
  {
    'saghen/blink.cmp',
    version = 'v0.*',
    dependencies = {
      'rafamadriz/friendly-snippets',
      'xzbdmw/colorful-menu.nvim',
    },
    event = 'InsertEnter',
    keys = {
      {
        '<leader>tC',
        function()
          -- Initialize variable if it isn't
          if vim.b.completion == nil then
            vim.b.completion = true
          end

          vim.b.completion = not vim.b.completion

          if vim.b.completion then
            vim.notify('Completion enabled', vim.log.levels.INFO)
          else
            vim.notify('Completion disabled', vim.log.levels.INFO)
          end
        end,
        desc = 'Toggle [C]ompletion',
      },
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = 'none',
        ['<C-CR>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<C-y>'] = { 'select_and_accept' },
        ['<C-e>'] = { 'hide' },

        ['<C-p>'] = { 'select_prev', 'fallback' },
        ['<C-n>'] = { 'select_next', 'fallback' },

        ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },

        ['<Tab>'] = { 'snippet_forward', 'fallback' },
        ['<S-Tab>'] = { 'snippet_backward', 'fallback' },

        ['<C-h>'] = { 'show_signature', 'hide_signature', 'fallback' },
      },

      completion = {
        accept = {
          auto_brackets = {
            enabled = true,
          },
        },
        menu = {
          draw = {
            columns = { { 'kind_icon' }, { 'label', gap = 1 } },
            components = {
              label = {
                text = function(ctx)
                  return require('colorful-menu').blink_components_text(ctx)
                end,
                highlight = function(ctx)
                  return require('colorful-menu').blink_components_highlight(ctx)
                end,
              },
            },
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 0,
        },
        ghost_text = {
          enabled = false,
        },
      },

      appearance = {
        -- Sets the fallback highlight groups to nvim-cmp's highlight groups
        -- Useful for when your theme doesn't support blink.cmp
        -- will be removed in a future release
        use_nvim_cmp_as_default = false,
        -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono',
      },

      -- default list of enabled providers defined so that you can extend it
      -- elsewhere in your config, without redefining it, via `opts_extend`
      sources = {
        -- add lazydev to your completion providers
        default = { 'lsp', 'path', 'snippets', 'buffer', 'lazydev' },
        providers = {
          lazydev = {
            name = 'LazyDev',
            module = 'lazydev.integrations.blink',
            score_offset = 100,
          },
        },
      },

      cmdline = {
        enabled = false,
      },

      -- experimental signature help support
      signature = {
        enabled = true,
      },
    },
  },
}
