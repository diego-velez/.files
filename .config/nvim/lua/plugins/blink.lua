---@module "lazy"
---@type LazySpec
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
    version = '1.*',
    dependencies = {
      'xzbdmw/colorful-menu.nvim',
      'mikavilpas/blink-ripgrep.nvim',
      'archie-judd/blink-cmp-words',
      'disrupted/blink-cmp-conventional-commits',
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
      {
        '<leader>tg',
        function()
          if vim.b.grep_completion == nil then
            vim.b.grep_completion = false
          end

          vim.b.grep_completion = not vim.b.grep_completion

          if vim.b.grep_completion then
            vim.notify('Grep completion enabled', vim.log.levels.INFO)
          else
            vim.notify('Grep completion disabled', vim.log.levels.INFO)
          end
        end,
        desc = '[T]oggle [G]rep in autocompletion',
      },
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = 'none',
        ['<C-CR>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<C-y>'] = { 'select_and_accept' },
        ['<C-e>'] = { 'cancel' },

        ['<C-p>'] = { 'select_prev', 'fallback' },
        ['<C-n>'] = { 'select_next', 'fallback' },

        ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },

        ['<Tab>'] = {
          function(_)
            local can_expand = #MiniSnippets.expand { insert = false } > 0
            if can_expand then
              vim.schedule(MiniSnippets.expand)
              return true
            end
            local is_active = MiniSnippets.session.get() ~= nil
            if is_active then
              MiniSnippets.session.jump 'next'
              return true
            end
            return false
          end,
          'fallback',
        },
        ['<S-Tab>'] = {
          function()
            local is_active = MiniSnippets.session.get() ~= nil
            if is_active then
              MiniSnippets.session.jump 'prev'
              return true
            end
            return false
          end,
          'fallback',
        },

        ['<C-h>'] = { 'show_signature', 'hide_signature', 'fallback' },
      },

      completion = {
        accept = {
          auto_brackets = {
            enabled = false,
          },
        },
        menu = {
          draw = {
            columns = { { 'kind_icon' }, { 'label', 'label_description', gap = 1 } },
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
          border = 'none',
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

      sources = {
        default = function()
          local success, node = pcall(vim.treesitter.get_node)
          if
            success
            and node
            and vim.tbl_contains(
              { 'comment', 'comment_content', 'line_comment', 'block_comment' },
              node:type()
            )
          then
            return { 'path', 'buffer', 'dictionary', 'thesaurus', 'ripgrep' }
          end

          local defacto = { 'lsp', 'path', 'buffer' }

          -- Only show ripgrep if we have it on for the buffer
          if vim.b.grep_completion then
            table.insert(defacto, 'ripgrep')
          end

          return defacto
        end,
        providers = {
          lsp = {
            fallbacks = {},
          },
          path = {
            opts = {
              get_cwd = function(_)
                return vim.uv.cwd()
              end,
            },
          },
          lazydev = {
            name = 'LazyDev',
            module = 'lazydev.integrations.blink',
            score_offset = 100,
          },
          ripgrep = {
            module = 'blink-ripgrep',
            name = 'Ripgrep',
            ---@module "blink-ripgrep"
            ---@type blink-ripgrep.Options
            opts = {},
            transform_items = function(_, items)
              for _, item in ipairs(items) do
                item.labelDetails = {
                  description = '(rg)',
                }
              end
              return items
            end,
          },
          -- Use the thesaurus source
          thesaurus = {
            name = 'blink-cmp-words',
            module = 'blink-cmp-words.thesaurus',
            -- All available options
            opts = {
              -- A score offset applied to returned items.
              -- By default the highest score is 0 (item 1 has a score of -1, item 2 of -2 etc..).
              score_offset = 0,

              -- Default pointers define the lexical relations listed under each definition,
              -- see Pointer Symbols below.
              -- Default is as below ("antonyms", "similar to" and "also see").
              pointer_symbols = { '!', '&', '^' },
            },
            transform_items = function(_, items)
              for _, item in ipairs(items) do
                item.labelDetails = {
                  description = '(thesaurus)',
                }
              end
              return items
            end,
          },

          -- Use the dictionary source
          dictionary = {
            name = 'blink-cmp-words',
            module = 'blink-cmp-words.dictionary',
            -- All available options
            opts = {
              -- The number of characters required to trigger completion.
              -- Set this higher if completion is slow, 3 is default.
              dictionary_search_threshold = 3,

              -- See above
              score_offset = 0,

              -- See above
              pointer_symbols = { '!', '&', '^' },
            },
            transform_items = function(_, items)
              for _, item in ipairs(items) do
                item.labelDetails = {
                  description = '(dictionary)',
                }
              end
              return items
            end,
          },
          conventional_commits = {
            name = 'Conventional Commits',
            module = 'blink-cmp-conventional-commits',
          },
        },
        per_filetype = {
          text = { 'dictionary', 'ripgrep' },
          markdown = { 'thesaurus', 'ripgrep' },
          lua = { 'lazydev', inherit_defaults = true },
          gitcommit = { 'conventional_commits', 'buffer', 'thesaurus', 'dictionary', 'ripgrep' },
        },
      },

      cmdline = {
        enabled = true,
        keymap = {
          preset = 'inherit',
          ['<tab>'] = { 'show_and_insert', 'select_next' },
          ['<S-tab>'] = { 'show_and_insert', 'select_prev' },
        },
      },

      fuzzy = {
        implementation = 'prefer_rust_with_warning',
      },

      -- experimental signature help support
      signature = {
        enabled = true,
      },
    },
  },
}
