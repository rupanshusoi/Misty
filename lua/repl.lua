local misty = require('misty')

local global_env = {}

while true do
  io.write('Misty$ ')
  local line = io.read()
  local value = misty.interpret(line, global_env)
  if value then
    misty.my_printn(value)
  end
end
