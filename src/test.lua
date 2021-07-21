Misty = require('misty')

local function pretty_print(t)
  if type(t) == 'number' or type(t) == 'string' or type(t) == 'boolean' then
    print(t)
    return
  end

  print('Length ', #t)
  for k, v in pairs(t) do
    print(k..': '..tostring(v))
  end
end

E = Misty.run_file('test.scm')
pretty_print(E)

