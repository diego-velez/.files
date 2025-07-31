return {
  'gbprod/yanky.nvim',
  keys = {
    {
      '<leader>p',
      function()
        vim.cmd [[YankyRingHistory]]
      end,
      mode = { 'n', 'x' },
      desc = 'Open Yank History',
    },
    { 'y', '<Plug>(YankyYank)', mode = { 'n', 'x' }, desc = 'Yank Text' },
    { 'p', '<Plug>(YankyPutAfter)', mode = { 'n', 'x' }, desc = 'Put Text After Cursor' },
    { 'P', '<Plug>(YankyPutBefore)', mode = { 'n', 'x' }, desc = 'Put Text Before Cursor' },
    { 'gp', '<Plug>(YankyGPutAfter)', mode = { 'n', 'x' }, desc = 'Put Text After Selection' },
    { 'gP', '<Plug>(YankyGPutBefore)', mode = { 'n', 'x' }, desc = 'Put Text Before Selection' },
    { '[y', '<Plug>(YankyCycleForward)', desc = 'Cycle Forward Through Yank History' },
    { ']y', '<Plug>(YankyCycleBackward)', desc = 'Cycle Backward Through Yank History' },
    { ']p', '<Plug>(YankyPutIndentAfterLinewise)', desc = 'Paste after line' },
    {
      '[p',
      '<Plug>(YankyPutIndentBeforeLinewise)',
      desc = 'Paste before line',
    },
    { ']P', '<Plug>(YankyPutIndentAfterLinewise)', desc = 'Paste after line' },
    {
      '[P',
      '<Plug>(YankyPutIndentBeforeLinewise)',
      desc = 'Paste before line',
    },
  },
  opts = {
    highlight = { timer = 150 },
  },
}
