return {
  'nvimtools/none-ls.nvim',
  enabled = false,
  opts = {
    debug = true,
  },
  config = function(_, opts)
    local null_ls = require 'null-ls'
    null_ls.setup(opts)

    local helpers = require 'null-ls.helpers'

    local java_maven = {
      name = 'Java Maven',
      method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
      filetypes = { 'java' },
      generator = helpers.generator_factory {
        command = './mvnw',
        args = {
          'install',
          '--batch-mode',
          '--update-snapshots',
        },
        format = 'raw',
        to_stdin = false,
        from_stderr = true,
        ignore_stderr = true,
        timeout = 60000,
        check_exit_code = {
          1,
        },
        on_output = function(params, done)
          if string.find(params.output, 'BUILD FAILURE') then
            vim.notify('Build Failed', vim.log.levels.ERROR)
          else
            vim.notify('Build Success', vim.log.levels.INFO)
          end

          local diagnostics = {}
          for filepath, row, col, message in
            params.output:gmatch '%[ERROR%] (.-):%[(%d+),(%d+)%] (.-)\n'
          do
            -- Prevent bug where it matches "COMPILATION ERROR" part too
            local _, j = string.find(filepath, '%[ERROR%] ')
            if j ~= nil then
              filepath = string.sub(filepath, j + 1)
            end

            -- Only show diagnostics for file that is currently open
            -- Needs this because Maven returns error for all files in project
            if filepath == params.bufname then
              table.insert(diagnostics, {
                message = message,
                row = row,
                col = col,
                severity = 1,
                source = 'Java Maven',
              })
            end
          end

          done(diagnostics)
        end,
      },
    }
    null_ls.register(java_maven)
  end,
}
