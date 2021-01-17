local types = require('types')
local parser = require('parser')

local misty = {}

function misty.bool2hash(bool)
  if bool then return '#t' else return '#f' end
end

function misty.apply_primitive(ast)
  if ast.func == '+' then
    return misty.evaluate(ast.args[1]) + misty.evaluate(ast.args[2])

  elseif ast.func == '-' then
    return misty.evaluate(ast.args[1]) - misty.evaluate(ast.args[2])

  elseif ast.func == '*' then
    return misty.evaluate(ast.args[1]) * misty.evaluate(ast.args[2])

  elseif ast.func == '//' then
    return misty.evaluate(ast.args[1]) // misty.evaluate(ast.args[2])

  elseif ast.func == 'car' then
    return misty.evaluate(ast.args[1]).values[1]

  elseif ast.func == 'cdr' then
    local e = misty.evaluate(ast.args[1])
    table.remove(e.values, 1)
    return e

  elseif ast.func == 'cons' then
    local e = misty.evaluate(ast.args[2]) 
    assert(type(e) == 'table' and e.__type == 'AstList', 'second arg to cons must be AstList')
    table.insert(e.values, 1, misty.evaluate(ast.args[1]))
    return e

  elseif ast.func == 'add1' then
    return misty.evaluate(ast.args[1]) + 1

  elseif ast.func == 'sub1' then
    return misty.evaluate(ast.args[1]) - 1

  elseif ast.func == 'number?' then
    return types.AstAtom:new({ value = misty.bool2hash(type(misty.evaluate(ast.args[1])) == 'number') })

  elseif ast.func == 'atom?' then
    local e = misty.evaluate(ast.args[1])
    return types.AstAtom:new({ value = misty.bool2hash((type(e) == 'number') or (e.__type == 'AstAtom')) })

  elseif ast.func == 'zero?' then
    return types.AstAtom:new({ value = bool2hash(misty.evaluate(ast.args[1]) == 0) })

  else
    assert(false, 'unknown primitive function: ' .. tostring(ast.func))

  end
end

function misty.evaluate(ast)
  if type(ast) == 'number' then
    return ast

  elseif ast.__type == 'AstPrimitive' then
    return misty.apply_primitive(ast)

  elseif ast.__type == 'AstList' then
    return ast

  elseif ast.__type == 'AstAtom' then
    return ast.value

  else
    assert(false)

  end
end

function misty.interpret(S)
  return misty.evaluate(parser.parse(parser.tokenize(S)))
end

function misty.my_print(ast)
  if type(ast) == 'number' then
    io.write(tostring(ast) .. ' ')

  elseif ast.__type == 'AstList' then
    io.write('( ')
    for _, value in pairs(ast.values) do
      misty.my_print(value)
    end
    io.write(') ')

  elseif ast.__type == 'AstAtom' then
    io.write(ast.value .. ' ')

  else
    assert(false)

  end
end

function misty.my_printn(ast)
  misty.my_print(ast)
  io.write('\n')
end

function misty.interpret_and_printn(program)
  misty.my_printn(misty.interpret(program))
end

return misty
