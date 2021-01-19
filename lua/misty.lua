local types = require('types')
local parser = require('parser')

local misty = {}

function misty.bool2hash(bool)
  if bool then return '#t' else return '#f' end
end

function misty.apply_primitive(ast)

  local lookup = {

    ['+'] = function() return misty.evaluate(ast.args[1]) + misty.evaluate(ast.args[2]) end,

    ['-'] = function() return misty.evaluate(ast.args[1]) - misty.evaluate(ast.args[2]) end,

    ['*'] = function() return misty.evaluate(ast.args[1]) * misty.evaluate(ast.args[2]) end,

    ['//'] = function() return misty.evaluate(ast.args[1]) // misty.evaluate(ast.args[2]) end,

    ['car'] = function() return misty.evaluate(ast.args[1]).values[1] end,

    ['cdr'] = function()
      local e = misty.evaluate(ast.args[1])
      table.remove(e.values, 1)
      return e
    end,

    ['cons'] = function()
      local e = misty.evaluate(ast.args[2]) 
      assert(type(e) == 'table' and e.__type == 'AstList', 'second arg to cons must be AstList')
      table.insert(e.values, 1, misty.evaluate(ast.args[1]))
      return e
    end,

    ['add1'] = function() return misty.evaluate(ast.args[1]) + 1 end,

    ['sub1'] = function() return misty.evaluate(ast.args[1]) - 1 end,

    ['number?'] = function()
      return types.AstAtom:new{ value = misty.bool2hash(type(misty.evaluate(ast.args[1])) == 'number') }
    end,

    ['atom?'] = function()
      local e = misty.evaluate(ast.args[1])
      return types.AstAtom:new{ value = misty.bool2hash((type(e) == 'number') or (e.__type == 'AstAtom')) }
    end,

    ['zero?'] = function()
      return types.AstAtom:new{ value = misty.bool2hash(misty.evaluate(ast.args[1]) == 0) }
    end,

    ['quote'] = function()
      return ast.args[1]
    end,

  }

  return lookup[ast.func.value]()
end

function misty.apply_cond(ast)
  for line = 1, #ast.cond_lines do
    local cond = misty.evaluate(ast.cond_lines[line].cond)

    if cond == '#t' or cond.value == '#t' then
      return misty.evaluate(ast.cond_lines[line].stat)
    end

  end
  assert(false, 'no true cond-line in cond expression')
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

  elseif ast.__type == 'AstCond' then
    return misty.apply_cond(ast)

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
