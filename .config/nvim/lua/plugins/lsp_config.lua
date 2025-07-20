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
  },
  config = function()
    -- vim.lsp.set_log_level 'off' WARN: this might be needed if getting lsp log too big ah type shi
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc)
          vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end
        local client = vim.lsp.get_client_by_id(event.data.client_id)

        map('gd', function()
          require('mini.pick').LspPicker('definition', true)
        end, '[G]oto [D]efinition')

        map('gr', function()
          require('mini.pick').LspPicker('references', true)
        end, '[G]oto [R]eferences')

        map('gI', function()
          require('mini.pick').LspPicker('implementation', true)
        end, '[G]oto [I]mplementation')

        map('gy', function()
          require('mini.pick').LspPicker('type_definition', true)
        end, '[G]oto T[y]pe Definition')

        map('gD', function()
          require('mini.pick').LspPicker('declaration', true)
        end, '[G]oto [D]eclaration')

        map('<leader>ca', vim.lsp.buf.code_action, 'Code [A]ction')

        -- Show hover with window
        vim.api.nvim_create_autocmd({ 'VimEnter', 'VimResized' }, {
          group = vim.api.nvim_create_augroup('DVT Hover', { clear = true }),
          desc = 'Setup LSP hover window',
          buffer = event.buf,
          callback = function()
            local width = math.floor(vim.o.columns * 0.8)
            local height = math.floor(vim.o.lines * 0.3)

            vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
              border = 'rounded',
              max_width = width,
              max_height = height,
            })
          end,
        })

        map('h', vim.lsp.buf.hover, '[H]over')
        vim.keymap.set('n', 'K', '<nop>')

        if
          client
          and client:supports_method(vim.lsp.protocol.Methods.textDocument_codeLens, event.buf)
        then
          map('<leader>cc', vim.lsp.codelens.run, '[C]odelens')
          map('<leader>cC', vim.lsp.codelens.refresh, 'Refresh [C]odelens')
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
          end, '[T]oggle [I]nlay Hints')
        end
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
