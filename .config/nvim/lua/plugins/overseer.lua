---@module "lazy"
---@type LazyPluginSpec
return {
  'stevearc/overseer.nvim',
  cmd = {
    'OverseerOpen',
    'OverseerClose',
    'OverseerToggle',
    'OverseerSaveBundle',
    'OverseerLoadBundle',
    'OverseerDeleteBundle',
    'OverseerRunCmd',
    'OverseerRun',
    'OverseerInfo',
    'OverseerBuild',
    'OverseerQuickAction',
    'OverseerTaskAction',
    'OverseerClearCache',
  },
  keys = {
    { '<leader>ow', '<cmd>OverseerToggle<cr>', desc = 'Task list' },
    { '<leader>oo', '<cmd>OverseerRun<cr>', desc = 'Run task' },
    { '<leader>oq', '<cmd>OverseerQuickAction<cr>', desc = 'Action recent task' },
    { '<leader>oi', '<cmd>OverseerInfo<cr>', desc = 'Overseer Info' },
    { '<leader>ob', '<cmd>OverseerBuild<cr>', desc = 'Task builder' },
    { '<leader>ot', '<cmd>OverseerTaskAction<cr>', desc = 'Task action' },
    { '<leader>oc', '<cmd>OverseerClearCache<cr>', desc = 'Clear cache' },
  },
  ---@module 'overseer'
  ---@type overseer.Config
  opts = {
    dap = false,
    task_list = {
      direction = 'right',
      bindings = {
        ['?'] = 'ShowHelp',
        ['g?'] = 'ShowHelp',
        ['<CR>'] = 'RunAction',
        ['<C-e>'] = 'Edit',
        ['o'] = 'Open',
        ['<C-v>'] = 'OpenVsplit!',
        ['<C-h>'] = 'OpenSplit',
        ['<C-f>'] = 'OpenFloat',
        ['<C-q>'] = 'OpenQuickFix',
        ['p'] = 'TogglePreview',
        ['<C-right>'] = false,
        ['<C-left>'] = false,
        ['<C-down>'] = 'IncreaseAllDetail',
        ['<C-up>'] = 'DecreaseAllDetail',
        ['{'] = 'DecreaseWidth',
        ['}'] = 'IncreaseWidth',
        ['['] = 'PrevTask',
        [']'] = 'NextTask',
        ['<C-u>'] = 'ScrollOutputUp',
        ['<C-d>'] = 'ScrollOutputDown',
        ['q'] = 'Close',
      },
    },
    form = {
      win_opts = {
        winblend = 0,
      },
    },
    confirm = {
      win_opts = {
        winblend = 0,
      },
    },
    task_win = {
      win_opts = {
        winblend = 0,
      },
    },
  },
  config = function(_, config)
    local overseer = require 'overseer'
    overseer.setup(config)

    local tags = require('overseer.constants').TAG

    ---@module "overseer"
    ---@type overseer.TemplateDefinition
    overseer.register_template {
      name = 'Maven Test',
      builder = function(_)
        local files = vim.fs.find(
          { 'mvnw' },
          { upward = true, limit = math.huge, type = 'file', path = vim.fn.expand '%:p' }
        )
        local cwd = vim.fs.dirname(files[1]) or vim.uv.cwd()
        local rel_cwd = vim.fs.basename(cwd)
        ---@type overseer.TaskDefinition
        return {
          cmd = './mvnw',
          args = { 'test' },
          name = string.format('Maven Test in %s', rel_cwd),
          cwd = cwd,
        }
      end,
      tags = { tags.TEST },
      condition = {
        callback = function(search)
          local files = vim.fs.find(
            { 'mvnw' },
            { upward = true, limit = math.huge, type = 'file', path = search.dir }
          )
          return #files > 0
        end,
      },
    }

    ---@type overseer.TemplateDefinition
    overseer.register_template {
      name = 'Maven Clean',
      builder = function(_)
        local files = vim.fs.find(
          { 'mvnw' },
          { upward = true, limit = math.huge, type = 'file', path = vim.fn.expand '%:p' }
        )
        local cwd = vim.fs.dirname(files[1]) or vim.uv.cwd()
        local rel_cwd = vim.fs.basename(cwd)
        ---@type overseer.TaskDefinition
        return {
          cmd = './mvnw',
          args = { 'clean' },
          name = string.format('Maven Clean in %s', rel_cwd),
          cwd = cwd,
        }
      end,
      tags = { tags.CLEAN },
      condition = {
        callback = function(search)
          local files = vim.fs.find(
            { 'mvnw' },
            { upward = true, limit = math.huge, type = 'file', path = search.dir }
          )
          return #files > 0
        end,
      },
    }

    ---@type overseer.TemplateDefinition
    overseer.register_template {
      name = 'Maven Build',
      builder = function(_)
        local files = vim.fs.find(
          { 'mvnw' },
          { upward = true, limit = math.huge, type = 'file', path = vim.fn.expand '%:p' }
        )
        local cwd = vim.fs.dirname(files[1]) or vim.uv.cwd()
        local rel_cwd = vim.fs.basename(cwd)
        ---@type overseer.TaskDefinition
        return {
          cmd = './mvnw',
          args = { 'install', '-U', '-DskipTests' },
          name = string.format('Maven Build in %s', rel_cwd),
          cwd = cwd,
        }
      end,
      tags = { tags.BUILD },
      condition = {
        callback = function(search)
          local files = vim.fs.find(
            { 'mvnw' },
            { upward = true, limit = math.huge, type = 'file', path = search.dir }
          )
          return #files > 0
        end,
      },
    }

    ---@type overseer.TemplateDefinition
    overseer.register_template {
      name = 'Upload Service (Skaffold)',
      builder = function(_)
        local files = vim.fs.find(
          { 'skaffold.yaml' },
          { upward = true, limit = math.huge, type = 'file', path = vim.fn.expand '%:p' }
        )
        vim.print(vim.inspect(files))
        local cwd = vim.fs.dirname(files[1]) or vim.uv.cwd()
        local rel_cwd = vim.fs.basename(cwd)
        ---@type overseer.TaskDefinition
        return {
          cmd = 'skaffold',
          args = {
            'run',
            '--profile',
            'dev',
            '--kube-context=gke_diveto-louhi-test_us-central1_louhi',
            '--skip-tests',
            '--default-repo="us-central1-docker.pkg.dev/diveto-louhi-test/microservices"',
          },
          name = string.format('Upload %s', rel_cwd),
          cwd = cwd,
        }
      end,
      tags = { tags.BUILD },
      condition = {
        callback = function(search)
          local files = vim.fs.find(
            { 'skaffold.yaml' },
            { upward = true, limit = math.huge, type = 'file', path = search.dir }
          )
          return #files > 0
        end,
      },
    }

    ---@type overseer.TemplateDefinition
    overseer.register_template {
      name = 'Run Frontend (Real)',
      builder = function(_)
        local files = vim.fs.find(
          { 'skaffold-local.yaml' },
          { upward = true, limit = math.huge, type = 'file', path = vim.fn.expand '%:p' }
        )
        local cwd = vim.fs.dirname(files[1]) or vim.uv.cwd()
        ---@type overseer.TaskDefinition
        return {
          cmd = 'skaffold run --profile local --filename skaffold-local.yaml && gcloud container clusters get-credentials louhi --region us-central1 --project diveto-louhi-test && kubectl port-forward --namespace louhi $(kubectl get pod --namespace louhi --selector="app=api-personal-gateway-service" --output jsonpath=\'{.items[0].metadata.name}\') 8080:8080',
          name = 'Run Frontend (Real)',
          cwd = cwd,
        }
      end,
      tags = { tags.RUN },
      condition = {
        dir = 'ui/frontend',
      },
    }
  end,
}
