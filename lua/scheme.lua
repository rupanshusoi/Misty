-- Add types
local AstPrimitive = { __type = 'AstPrimitive' }
local AstList      = { __type = 'AstList'      }
local AstAtom      = { __type = 'AstAtom'      }

function AstPrimitive:new(o)
  o = o or { args = {} }
  setmetatable(o, self)
  self.__index = self
  return o
end

function AstList:new(o)
  o = o or { values = {} }
  setmetatable(o, self)
  self.__index = self
  return o
end

function AstAtom:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

local function apply_primitive(ast)
  if ast.func == '+' then
    return evaluate(ast.args[1]) + evaluate(ast.args[2])
  elseif ast.func == '-' then
    return evaluate(ast.args[1]) - evaluate(ast.args[2])
  elseif ast.func == '*' then
    return evaluate(ast.args[1]) * evaluate(ast.args[2])
  elseif ast.func == '//' then
    return evaluate(ast.args[1]) // evaluate(ast.args[2])
  elseif ast.func == 'car' then
    return evaluate(ast.args[1]).values[1]
  else
    assert(false, 'unknown primitive function: ' .. tostring(ast.func))
  end
end

local function find_closep(tokens, openp)
  local idx, paren = openp + 1, 0
  while idx < #tokens do
    if tokens[idx] == ')' then
      if paren == 0 then break end
      paren = paren - 1
    elseif tokens[idx] == '(' then
      paren = paren + 1
    end
    idx = idx + 1
  end
  return idx
end

local function parse(tokens, is_quoted)
  assert(#tokens > 2, 'S-expression too small')
  assert(tokens[1] == '(', 'expected LPAREN but got: ' .. tokens[1])
  assert(tokens[#tokens] == ')', 'expected RPAREN but got: ' .. tokens[#tokens])

  if is_quoted then
    -- Parse as a list if quoted
    local ast = AstList:new()

    -- Remove parens
    local tokens_trimmed = { table.unpack(tokens, 2, #tokens - 1) }

    local i = 1
    while i <= #tokens_trimmed do
  
      if tokens_trimmed[i] == '(' then
  
        local closep = find_closep(tokens_trimmed, i)
        table.insert(ast.values, parse({ table.unpack(tokens_trimmed, i, closep) }, is_quoted))
        i = closep + 1
  
      else
        table.insert(ast.values, AstAtom:new({ value = tokens_trimmed[i] }))
        i = i + 1
      end
    end
    return ast
  else
    -- Remove func and outermost parens
    local tokens_trimmed = { table.unpack(tokens, 3, #tokens - 1) }
  
    if tokens[2] == 'quote' then
      -- Parse as a list
      return parse(tokens_trimmed, true) 
    else
      -- Parse as a (primitive) function application
      local ast = AstPrimitive:new()
      ast.func = tokens[2]
    
      local i = 1
      while i <= #tokens_trimmed do
    
        if tokens_trimmed[i] == '(' then
    
          local closep = find_closep(tokens_trimmed, i)
          table.insert(ast.args, parse({ table.unpack(tokens_trimmed, i, closep) }))
          i = closep + 1
    
        elseif tonumber(tokens_trimmed[i]) then
          table.insert(ast.args, tonumber(tokens_trimmed[i]))
          i = i + 1
        else
          -- Must be an atom
          table.insert(ast.args, AstAtom:new({ value = tokens_trimmed[i] }))
          i = i + 1
        end
      end
      return ast
    end
  end
end

local function tokenize(S)
  local S, _ = S:gsub('%(', ' ( ')
  S, _ = S:gsub('%)', ' ) ')
  local tokens = {}
  for i in S:gmatch('%S+') do
    table.insert(tokens, i)
  end
  return tokens
end

-- Needs to be global
function evaluate(ast)
  if type(ast) == 'number' then
    return ast
  elseif ast.__type == 'AstPrimitive' then
    return apply_primitive(ast)
  elseif ast.__type == 'AstList' then
    return ast
  elseif ast.__type == 'AstAtom' then
    return ast.value
  else
    assert(false)
  end
end

local function interpret(S)
  return evaluate(parse(tokenize(S)))
end

function my_print(ast)
  if type(ast) == 'number' then
    io.write(tostring(ast) .. ' ')
  elseif ast.__type == 'AstList' then
    io.write('( ')
    for _, value in pairs(ast.values) do
      my_print(value)
    end
    io.write(') ')
  elseif ast.__type == 'AstAtom' then
    io.write(ast.value .. ' ')
  else
    assert(false)
  end
end

--my_print(interpret('(quote (quote (1 2 3)))'))
--my_print(interpret('(* (+ (// (- 16 2) 2) 3) 3)'))
--my_print(interpret('(+ 2 (+ (* 2 3) 5))'))
--my_print(interpret('(car (1 2 3))'))
--my_print(interpret('(car (1 (+ 2 3)))'))
my_print(interpret('(car (quote ((quote tears bears cries) bears pears)))'))
