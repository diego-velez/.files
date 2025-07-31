return {
  'neovim/nvim-lspconfig',
  dependencies = {
    {
      'mason-org/mason.nvim',
      version = '^1.0.0',
      ---@class MasonSettings
      opts = {
        ui = {
          keymaps = {
            toggle_help = '?',
          },
        },
      },
    },
    { 'mason-org/mason-lspconfig.nvim', version = '^1.0.0' },
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    'saghen/blink.cmp',
    'nvim-java/nvim-java',
    'saecki/live-rename.nvim',
    {
      'andrewferrier/debugprint.nvim',
      ---@module "debugprint"
      ---@type debugprint.GlobalOptions
      opts = {
        keymaps = {
          normal = {
            plain_below = '',
            plain_above = '',
            variable_below = '',
            variable_above = '',
            variable_below_alwaysprompt = '',
            variable_above_alwaysprompt = '',
            surround_plain = '',
            surround_variable = '',
            surround_variable_alwaysprompt = '',
            textobj_below = '',
            textobj_above = '',
            textobj_surround = '',
            toggle_comment_debug_prints = '',
            delete_debug_prints = '',
          },
          insert = {
            plain = '',
            variable = '',
          },
          visual = {
            variable_below = '',
            variable_above = '',
          },
        },
        display_counter = false,
      },
    },
  },
  config = function()
    -- vim.lsp.set_log_level 'off' WARN: this might be needed if getting lsp log too big ah type shi
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc)
          vim.keymap.set('n', keys, func, { buffer = event.buf, desc = desc })
        end
        local client = vim.lsp.get_client_by_id(event.data.client_id)

        map('gd', function()
          require('mini.pick').LspPicker('definition', true)
        end, 'LSP: [G]oto [D]efinition')

        map('gr', function()
          require('mini.pick').LspPicker('references', true)
        end, 'LSP: [G]oto [R]eferences')

        map('gI', function()
          require('mini.pick').LspPicker('implementation', true)
        end, 'LSP: [G]oto [I]mplementation')

        map('gy', function()
          require('mini.pick').LspPicker('type_definition', true)
        end, 'LSP: [G]oto T[y]pe Definition')

        map('gD', function()
          require('mini.pick').LspPicker('declaration', true)
        end, 'LSP: [G]oto [D]eclaration')

        map('<leader>ca', vim.lsp.buf.code_action, 'LSP: Code [A]ction')

        map('<leader>cr', function()
          require('live-rename').rename { insert = true }
        end, 'LSP: [R]ename')

        map('h', vim.lsp.buf.hover, 'LSP: [H]over')
        vim.keymap.set('n', 'K', '<nop>')

        if
          client
          and client:supports_method(vim.lsp.protocol.Methods.textDocument_codeLens, event.buf)
        then
          map('<leader>cc', vim.lsp.codelens.run, 'LSP: [C]odelens')
          map('<leader>cC', vim.lsp.codelens.refresh, 'LSP: Refresh [C]odelens')
        end

        if
          client
          and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf)
        then
          map('<leader>ti', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })

            if vim.lsp.inlay_hint.is_enabled { bufnr = event.buf } then
              vim.notify('Inlay hints enabled', vim.log.levels.INFO)
            else
              vim.notify('Inlay hints disabled', vim.log.levels.INFO)
            end
          end, 'LSP: [T]oggle [I]nlay Hints')
        end

        -- [H]ere aka we are *here* in the code
        map('g?h', function()
          require('debugprint').debugprint {}
        end, 'We are [h]ere (below)')
        map('g?H', function()
          require('debugprint').debugprint { above = true }
        end, 'We are [h]ere (above)')

        -- [V]ariable aka this is the value of said variable
        map('g?v', function()
          require('debugprint').debugprint { variable = true }
        end, 'This [v]ariable (below)')
        map('g?V', function()
          require('debugprint').debugprint { above = true, variable = true }
        end, 'This [v]ariable (above)')

        -- [P]rompt aka we want to see the value of user input variable
        map('g?p', function()
          require('debugprint').debugprint { variable = true, ignore_treesitter = true }
        end, '[P]rompt for variable (below)')
        map('g?P', function()
          require('debugprint').debugprint { above = true, variable = true, ignore_treesitter = true }
        end, '[P]rompt for variable (above)')

        -- Other operations
        map('g?d', function()
          require('debugprint.printtag_operations').deleteprints()
        end, '[D]elete all debugprint in current buffer')
        map('g?t', function()
          require('debugprint.printtag_operations').toggle_comment_debugprints()
        end, '[T]oggle debugprint statements')
        map('g?s', function()
          MiniPick.builtin.grep({ pattern = 'DEBUGPRINT:' }, nil)
        end, '[S]earch all debugprint statements')
      end,
    })

    local capabilities = require('blink.cmp').get_lsp_capabilities()

    local servers = {
      -- clangd = {},
      gopls = {
        settings = {
          gopls = {
            ['ui.inlayhint.hints'] = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
          },
        },
      },
      -- TODO: Figure out if I should be using pyright instead
      pylsp = {},

      lua_ls = {
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',
            },
          },
        },
      },
      htmx = {
        filetypes = {
          'gohtml',
          'gohtmltmpl',
          'handlebars',
          'html',
          'mustache',
          'templ',
        },
      },
      asm_lsp = {
        single_file_support = true,
      },
      jdtls = {
        settings = {
          java = {
            configuration = {
              runtimes = {
                {
                  name = 'JavaSE-21',
                  path = '/usr/local/google/home/diveto/.sdkman/candidates/java/21.0.1-tem/bin',
                  default = true,
                },
              },
            },
          },
        },
        handlers = {
          -- By assigning an empty function, you can remove the notifications
          -- printed to the cmd
          ['$/progress'] = function(_, result, ctx) end,
        },
      },
    }

    local ensure_installed = vim.tbl_keys(servers or {})
    vim.list_extend(ensure_installed, {
      'stylua', -- Used to format Lua code
      'bash-language-server',
      'html-lsp',
      'htmx-lsp',
      'css-lsp',
      'json-lsp',
    })
    require('mason-tool-installer').setup { ensure_installed = ensure_installed }

    require('java').setup()

    require('mason-lspconfig').setup {
      ensure_installed = {},
      automatic_installation = false,
      handlers = {
        function(server_name)
          local server = servers[server_name] or {}
          server.capabilities =
            vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
          require('lspconfig')[server_name].setup(server)
        end,
      },
    }
  end,
}
