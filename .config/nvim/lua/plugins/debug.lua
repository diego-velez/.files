return {
  'andrewferrier/debugprint.nvim',
  opts = {
    keymaps = {
      normal = {
        -- [H]ere aka we are *here* in the code
        plain_below = 'g?h',
        plain_above = 'g?H',
        -- [V]ariable aka this is the value of said variable
        variable_below = 'g?v',
        variable_above = 'g?V',
        -- [P]rompt aka we want to see the value of a variable
        variable_below_alwaysprompt = 'g?p',
        variable_above_alwaysprompt = 'g?P',
        -- [M]otion aka do a motion after to select variable
        textobj_below = 'g?m',
        textobj_above = 'g?M',
        toggle_comment_debug_prints = 'g?t',
        delete_debug_prints = 'g?d',
      },
      insert = {
        plain = '',
        variable = '',
      },
      visual = {
        variable_below = 'g?v',
        variable_above = 'g?V',
      },
    },
    commands = {
      toggle_comment_debug_prints = 'ToggleCommentDebugPrints',
      delete_debug_prints = 'DeleteDebugPrints',
      reset_debug_prints_counter = 'ResetDebugPrintsCounter',
    },
  },
}
