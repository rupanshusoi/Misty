local types = require('types')
local parser = require('parser')

local misty = {}

-- From lua-users.org/wiki/CopyTable
function misty.deepcopy(orig, copies)
  copies = copies or {}
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
    if copies[orig] then
      copy = copies[orig]
    else
      copy = {}
      copies[orig] = copy
      for orig_key, orig_value in next, orig, nil do
        copy[misty.deepcopy(orig_key, copies)] = misty.deepcopy(orig_value, copies)
      end
      setmetatable(copy, misty.deepcopy(getmetatable(orig), copies))
    end
  else -- number, string, boolean, etc
    copy = orig
  end
  return copy
end

function misty.bool2hash(bool)
  if bool then return '#t' else return '#f' end
end

function misty.apply_primitive(ast, env)
  if ast.func.value == '+' then
    return misty.evaluate(ast.args[1], env) + misty.evaluate(ast.args[2], env)

  elseif ast.func.value == '-' then
    return misty.evaluate(ast.args[1], env) - misty.evaluate(ast.args[2], env)

  elseif ast.func.value == '*' then
    return misty.evaluate(ast.args[1], env) * misty.evaluate(ast.args[2], env)

  elseif ast.func.value == '//' then
    return misty.evaluate(ast.args[1], env) // misty.evaluate(ast.args[2], env)

  elseif ast.func.value == 'car' then
    -- Hacky: We need to use tonumber(...) here because numbers inside a quote
    -- get parsed as AstAtoms, which are not numbers for Lua
    local e = misty.evaluate(ast.args[1], env).values[1]
    if tonumber(e.value) then
      return tonumber(e.value)
    else
      return e
    end

  elseif ast.func.value == 'cdr' then
    local copy = misty.deepcopy(misty.evaluate(ast.args[1], env))
    table.remove(copy.values, 1)
    return copy

  elseif ast.func.value == 'cons' then
    local e = misty.evaluate(ast.args[2], env) 
    local copy = misty.deepcopy(e)

    assert(type(e) == 'table' and e.__type == 'AstList', 'second arg to cons must be AstList')

    -- I'm not sure what's going on here. We need to put extra parens here to fix Lua's
    -- weird behaviour incase evaluate(...) does not return anything, but as far as I
    -- understand, evaluate(...) always returns something.
    table.insert(copy.values, 1, (misty.evaluate(ast.args[1], env)))

    return copy

  elseif ast.func.value == 'add1' then
    return misty.evaluate(ast.args[1], env) + 1

  elseif ast.func.value == 'sub1' then
    return misty.evaluate(ast.args[1], env) - 1

  elseif ast.func.value == 'number?' then
    return types.AstAtom:new{ value = misty.bool2hash(type(misty.evaluate(ast.args[1], env)) == 'number') }

  elseif ast.func.value == 'atom?' then
    local e = misty.evaluate(ast.args[1], env)
    return types.AstAtom:new{ value = misty.bool2hash((type(e) == 'number') or (e.__type == 'AstAtom')) }

  elseif ast.func.value == 'zero?' then
    return types.AstAtom:new{ value = misty.bool2hash(misty.evaluate(ast.args[1], env) == 0) }

  elseif ast.func.value == 'null?' then
    local e = misty.evaluate(ast.args[1], env)
    if type(e) == 'number' or e.__type ~= 'AstList' then
      return types.AstAtom:new{ value = misty.bool2hash(false) }
    else
      return types.AstAtom:new{ value = misty.bool2hash(#e.values == 0) }
    end

  elseif ast.func.value == 'quote' then
    return ast.args[1]

  elseif ast.func.value == 'print' then
    misty.my_printn(misty.evaluate(ast.args[1], env))

  elseif ast.func.value == 'define' then
    env[ast.args[1].name] = misty.evaluate(ast.args[2], env)

  else
    local func
    if ast.func.__type == 'AstAtom' then
      func = misty.lookup_id(ast.func.value, env)
    else
      func = ast.func
    end

    return misty.apply_non_primitive(func, ast.args, env)

  end
end

function misty.apply_non_primitive(func, args, env)
  local child = {}
  child.parent = env

  for i = 1, #func.formals.values do
    child[func.formals.values[i].value] = misty.evaluate(args[i], env)
  end

  return misty.evaluate(func.body, child)
end

function misty.apply_cond(ast, env)
  for line = 1, #ast.cond_lines do
    local cond = misty.evaluate(ast.cond_lines[line].cond, env)

    if cond == '#t' or cond.value == '#t' then
      return misty.evaluate(ast.cond_lines[line].stat, env)
    end

  end
  assert(false, 'no true cond-line in cond expression')
end

function misty.lookup_id(name, env)
  assert(env, 'environment can not be nil')
  if env[name] then
    return env[name]

  elseif env.parent then
    return misty.lookup_id(name, env.parent)

  else
    assert(false, 'identifier lookup failed')

  end
end

function misty.evaluate(ast, env)
  if type(ast) == 'number' then
    return ast

  elseif ast.__type == 'AstPrimitive' then
    return misty.apply_primitive(ast, env)

  elseif ast.__type == 'AstList' then
    return ast

  elseif ast.__type == 'AstAtom' then
    return ast.value

  elseif ast.__type == 'AstCond' then
    return misty.apply_cond(ast, env)

  elseif ast.__type == 'AstIdentifier' then
    return misty.lookup_id(ast.name, env)

  elseif ast.__type == 'AstLambda' then
    -- This should only be called from a (define id (lambda ...))
    return ast

  else
    assert(false)

  end
end

function misty.interpret(S, env)
  return misty.evaluate(parser.parse(S), env)
end

function misty.my_print(ast)
  if not ast then
    io.write('#<unspecified>')

  elseif type(ast) == 'number' then
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
    assert(false, ast.__type)

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
