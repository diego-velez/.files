local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

-- mini
add {
  name = 'mini.nvim',
  depends = {
    'Mofiqul/dracula.nvim.git',
    'nvim-treesitter/nvim-treesitter',
    'nvim-treesitter/nvim-treesitter-textobjects',
    'JoosepAlviste/nvim-ts-context-commentstring',
  },
}

now(function()
  require 'plugins.colorschemes'
  vim.cmd.colorscheme 'dracula'
end)

add 'nvim-treesitter/nvim-treesitter-context'

add 'folke/ts-comments.nvim'

now(function()
  require 'plugins.treesitter'
end)

now(function()
  require 'plugins.mini'
end)

-- blink
add {
  source = 'saghen/blink.cmp',
  depends = {
    'folke/lazydev.nvim',
    'justinsgithub/wezterm-types',
    'xzbdmw/colorful-menu.nvim',
    'mikavilpas/blink-ripgrep.nvim',
    'archie-judd/blink-cmp-words',
    'disrupted/blink-cmp-conventional-commits',
  },
  checkout = 'v1.6.0',
}

later(function()
  require 'plugins.blink'
end)

-- LSP
add {
  source = 'neovim/nvim-lspconfig',
  depends = {
    'mason-org/mason.nvim',
    'mason-org/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    'saghen/blink.cmp',
    'saecki/live-rename.nvim',
    'andrewferrier/debugprint.nvim',
  },
}

add {
  source = 'nvim-java/nvim-java',
  depends = {
    'nvim-java/lua-async-await',
    'nvim-java/nvim-java-refactor',
    'nvim-java/nvim-java-core',
    'nvim-java/nvim-java-test',
    'nvim-java/nvim-java-dap',
    'MunifTanjim/nui.nvim',
    'mfussenegger/nvim-dap',
    'JavaHello/spring-boot.nvim',
  },
}

later(function()
  require 'plugins.lsp_config'
end)

-- Formatter
add 'stevearc/conform.nvim'

later(function()
  require 'plugins.conform'
end)

-- Linter
add 'mfussenegger/nvim-lint'

later(function()
  require 'plugins.lint'
end)

-- Git integration
add 'lewis6991/gitsigns.nvim'

add {
  source = 'kdheepak/lazygit.nvim',
  depends = { 'nvim-lua/plenary.nvim' },
}

later(function()
  require 'plugins.git'
end)

-- Autopair stuff
add 'windwp/nvim-autopairs'

add 'windwp/nvim-ts-autotag'

later(function()
  require('nvim-autopairs').setup()
  require('nvim-ts-autotag').setup()
end)

-- Support TODO comments
add {
  source = 'folke/todo-comments.nvim',
  depends = { 'nvim-lua/plenary.nvim' },
}

later(function()
  require 'plugins.todo'
end)

-- Configure windows
add 'folke/edgy.nvim'

later(function()
  require 'plugins.edgy'
end)

-- Terminal support
add {
  source = 'nvzone/floaterm',
  depends = { 'nvzone/volt' },
}

later(function()
  require 'plugins.terminal'
end)

-- Automatically manage windows
add 'nvim-focus/focus.nvim'

later(function()
  require 'plugins.focus'
end)

-- Search and replace
add 'MagicDuck/grug-far.nvim'

later(function()
  require 'plugins.grug-far'
end)

-- Typescript stuff
add {
  source = 'pmizio/typescript-tools.nvim',
  depends = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
}

add 'dmmulroy/ts-error-translator.nvim'

later(function()
  require('typescript-tools').setup {}
  require('ts-error-translator').setup()
end)

-- Support markdown
add {
  source = 'MeanderingProgrammer/render-markdown.nvim',
  depends = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' },
}

later(function()
  require('render-markdown').setup()
end)

-- Task runner
add {
  source = 'diego-velez/overseer.nvim',
  checkout = 'task_output_filetype',
}

later(function()
  require 'plugins.overseer'
end)

-- My spear
add {
  source = 'diego-velez/spear.nvim',
  depends = { 'nvim-lua/plenary.nvim' },
}

later(function()
  require 'plugins.spear'
end)

-- Better diagnostics
add 'rachartier/tiny-inline-diagnostic.nvim'

later(function()
  require 'plugins.tiny'
end)

-- Undo tree
add 'mbbill/undotree'

later(function()
  vim.g.undotree_WindowLayout = 2
  vim.g.undotree_SetFocusWhenToggle = 1

  vim.keymap.set('n', '<leader>tu', vim.cmd.UndotreeToggle, { desc = 'Toggle [u]ndo tree' })
end)

-- Better yanking
add 'gbprod/yanky.nvim'

later(function()
  require 'plugins.yanky'
end)

-- Automatically set indentation
add 'NMAC427/guess-indent.nvim'

later(function()
  require('guess-indent').setup()
end)

-- Write files as root
add 'lambdalisue/vim-suda'

-- Cool cursor animations
add 'sphamba/smear-cursor.nvim'

later(function()
  require('smear_cursor').setup()
end)

-- Typst preview
add {
  source = 'chomosuke/typst-preview.nvim',
  checkout = 'v1.3.2',
}

later(function()
  require('typst-preview').setup {}
end)

-- HTTP request support
add 'mistweaverco/kulala.nvim'

-- stylua: ignore
vim.api.nvim_create_autocmd('FileType', {
  desc = 'Kulala specific keymaps',
  group = vim.api.nvim_create_augroup('DVT Kulala', { clear = true }),
  pattern = { 'http', 'rest' },
  callback = function(args)
    local kulala = require 'kulala'
    vim.keymap.set('n', '<leader>r', '', { buffer = args.buf, desc = '[R]un' })
    vim.keymap.set('n', '<leader>rs', kulala.run, { buffer = args.buf, desc = '[S]end request' })
    vim.keymap.set('n', '<leader>ra', kulala.run_all, { buffer = args.buf, desc = 'Send [A]ll requests' })
    vim.keymap.set('n', '<leader>rp', kulala.replay, { buffer = args.buf, desc = 'Run [P]revious' })
    vim.keymap.set('n', '<leader>ru', kulala.toggle_view, { buffer = args.buf, desc = 'Toggle UI' })
    vim.keymap.set('n', '{', kulala.jump_prev, { buffer = args.buf, desc = 'Previous Request' })
    vim.keymap.set('n', '}', kulala.jump_next, { buffer = args.buf, desc = 'Next Request' })
  end,
})

-- Focus mode
add 'folke/zen-mode.nvim'

later(function()
  require 'plugins.zen'
end)
