return {
  'nvim-focus/focus.nvim',
  lazy = false,
  opts = {
    commands = false,
    autoresize = {
      enable = true, -- Enable or disable auto-resizing of splits
      width = 100, -- Force width for the focused window
      height = 0, -- Force height for the focused window
      minwidth = 80, -- Force minimum width for the unfocused window
      minheight = 0, -- Force minimum height for the unfocused window
      focusedwindow_minwidth = 0, -- Force minimum width for the focused window
      focusedwindow_minheight = 0, -- Force minimum height for the focused window
      height_quickfix = 0, -- Set the height of quickfix panel
    },
    ui = {
      number = true, -- Display line numbers in the focussed window only
      relativenumber = true, -- Display relative line numbers in the focussed window only
      hybridnumber = true, -- Display hybrid line numbers in the focussed window only
      absolutenumber_unfocussed = false, -- Preserve absolute numbers in the unfocussed windows

      cursorline = true, -- Display a cursorline in the focussed window only
      cursorcolumn = false, -- Display cursorcolumn in the focussed window only
      colorcolumn = {
        enable = true, -- Display colorcolumn in the foccused window only
        list = '100', -- Set the comma-saperated list for the colorcolumn
      },
      signcolumn = true, -- Display signcolumn in the focussed window only
      winhighlight = false, -- Auto highlighting for focussed/unfocussed windows
    },
  },
}
