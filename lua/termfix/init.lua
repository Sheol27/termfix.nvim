local M = {}

function M.run_job(command_string) 
   local Job = require'plenary.job'

   local command_words = {}
   for word in command_string:gmatch("%S+") do table.insert(command_words, word) end

   local command = table.remove(command_words, 1)

   local cwd = vim.uv.cwd();

   Job:new({
      command = command,
      args = command_words,
      cwd = cwd,
      on_exit = function(j, return_val)
         local result = j:result()
         local stderr_result = j:stderr_result()

         for _, v in ipairs(stderr_result) do
            table.insert(result, v)
         end

         vim.schedule(function()
            vim.fn.setqflist({}, 'r', {
               lines = result,
            })

            vim.cmd('copen')
         end)
      end,
   }):start() 
end

function M.setup(opts)
   opts = opts or {}

   vim.keymap.set("n", "<Leader>m", function()
      vim.ui.input({
         prompt = "Compilation command: ",
         completion = "shellcmdline",
      }, M.run_job)
   end)
end

return M
