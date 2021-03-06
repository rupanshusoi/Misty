local Misty = {}

local function tokenize(S)
  local S, _ = S:gsub('%(', ' ( ')
  S, _ = S:gsub('%)', ' ) ')
  S, _ = S:gsub("'", " ' ")

  local tokens = {}
  for i in S:gmatch('%S+') do
    table.insert(tokens, i)
  end

  return tokens
end

local function find_closing_paren(tokens, opening_paren)
  local idx, counter = opening_paren, 1
  while counter ~= 0 do
    idx = idx + 1
    if tokens[idx] == '(' then
      counter = counter + 1
    elseif tokens[idx] == ')' then
      counter = counter - 1
    end
  end
  return idx
end

local function parse(tokens)
  assert(#tokens > 0)

  local program, i = {}, 2
  while i <= #tokens do
    if tokens[i] == '(' then
      local closing_paren = find_closing_paren(tokens, i)
      table.insert(program, parse{ table.unpack(tokens, i, closing_paren) })
      i = closing_paren
    elseif tokens[i] ~= ')' then
      table.insert(program, tokens[i])
    end
    i = i + 1
  end

  return program
end

local function eval(list, env)
  while true do
    if tonumber(list) then
      return tonumber(list)
    end
    if type(list) == 'string' then
      return env[list]
    end

    local op = list[1]
    if op == '+' then
      return eval(list[2], env) + eval(list[3], env)
    elseif op == '-' then
      return eval(list[2], env) - eval(list[3], env)
    elseif op == '*' then
      return eval(list[2], env) * eval(list[3], env)
    elseif op == 'zero?' then
      return eval(list[2], env) == 0
    elseif op == '<' then
      return eval(list[2], env) < eval(list[3], env)
    elseif op == '=' then
      return eval(list[2], env) == eval(list[3], env)
    elseif op == 'number?' then
      return type(eval(list[2], env)) == 'number'
    elseif op == 'null?' then
      return next(eval(list[2], env)) == nil
    elseif op == 'car' then
      return eval(list[2], env)[1]
    elseif op == 'cdr' then
      return { table.unpack(eval(list[2], env), 2) }
    elseif op == 'cons' then
      return { eval(list[2], env), table.unpack(eval(list[3], env)) }
    elseif op == 'if' then
      if eval(list[2], env) then
        list = list[3]
      else
        list = list[4]
      end
    elseif op == 'cond' then
      local arg = 2
      while true do
        if eval(list[arg][1], env) then
          list = list[arg][2]
          break
        end
        arg = arg + 1
      end
    elseif op == 'quote' then
      return list[2]
    elseif op == 'define' then
      env[list[2]] = eval(list[3], env)
      return nil
    elseif op == 'lambda' then
      return { list, env }
    else
      local op, closure = table.unpack(eval(op, env))

      setmetatable(closure, env)
      env.__index = env

      local new_env = {}
      setmetatable(new_env, closure)
      closure.__index = closure

      local arg = 2
      while arg <= #list do
        new_env[op[2][arg - 1]] = eval(list[arg], closure)
        arg = arg + 1
      end
      list = op[3]
      env = new_env
    end
  end
end

local function eval_file(file)
  local global_env = { ['else'] = true }
  local return_value

  local file = io.open(file)
  local tokens = tokenize(file:read('*all'))
  
  local i = 1
  while i <= #tokens do
    local closing_paren = find_closing_paren(tokens, i)
    return_value = eval(parse{ table.unpack(tokens, i, closing_paren) }, global_env)
    i = closing_paren + 1
  end

  file:close()
  return return_value
end

function Misty.run(source)
  return eval(parse(tokenize(source)), { ['else'] = true })
end

function Misty.run_file(file)
  return eval_file(file)
end

return Misty

