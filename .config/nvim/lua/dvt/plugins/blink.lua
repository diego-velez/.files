return {
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    dependencies = {
      { 'justinsgithub/wezterm-types', lazy = true },
      { 'Bilal2453/luvit-meta', lazy = true },
    },
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
        { path = 'wezterm-types', mods = { 'wezterm' } },
      },
    },
  },
  {
    'saghen/blink.cmp',
    version = 'v0.*',
    dependencies = 'rafamadriz/friendly-snippets',
    event = 'InsertEnter',
    -- allows extending the enabled_providers array elsewhere in your config
    -- without having to redefine it
    opts_extend = { 'sources.completion.enabled_providers' },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        ['<C-CR>'] = { 'show', 'select_and_accept', 'show_documentation' },
        ['<C-e>'] = { 'hide_documentation', 'hide' },
        ['<UP>'] = { 'select_prev', 'snippet_backward', 'fallback' },
        ['<DOWN>'] = { 'select_next', 'snippet_forward', 'fallback' },
        ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
      },

      completion = {
        menu = {
          draw = {
            treesitter = {
              'lsp',
            },
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 0,
          update_delay_ms = 0,
        },
        ghost_text = {
          enabled = true,
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
        cmdline = {},
        providers = {
          lazydev = {
            name = 'LazyDev',
            module = 'lazydev.integrations.blink',
            score_offset = 100,
          },
        },
      },

      -- experimental auto-brackets support
      -- completion = { accept = { auto_brackets = { enabled = true } } }

      -- experimental signature help support
      signature = {
        enabled = true,
      },
    },
  },
}
