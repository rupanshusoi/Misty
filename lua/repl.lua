local misty = require('misty')

while true do
  io.write('Misty$ ')
  local line = io.read()
  local value = misty.interpret(line)
  if value then
    misty.my_printn(value)
  end
end
