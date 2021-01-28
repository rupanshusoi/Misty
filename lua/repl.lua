local parser = require('parser')
local misty = require('misty')

local global_env = {}

if arg[1] then
  local file = io.open(arg[1])
  
  local program = file:read('*all')
  local tokens = parser.expand_quotes(parser.tokenize(program))
  
  local global_env = {}
  
  local i = 1
  while i < #tokens do
    local closep = parser.find_closep(tokens, i)
  
    local parse_tree = parser.main(parser.parse_list{ table.unpack(tokens, i, closep) })
    local value = misty.evaluate(parse_tree, global_env)
    if value then
      misty.my_printn(value)
    end
  
    i = closep + 1
  end
  
  file:close()

else
  print('\nMISTY: A Scheme interpreter in Lua')
  print('By Rupanshu Soi\n')
  while true do
    io.write('Misty$ ')
    local line = io.read()
    local value = misty.interpret(line, global_env)
    if value then
      misty.my_printn(value)
    end
  end

end
