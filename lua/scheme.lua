-- Add types
local AstPrimitive = { __type = 'AstPrimitive' }
local AstConst     = { __type = 'AstConst'     }
local AstList      = { __type = 'AstList'      }

function AstPrimitive:new(o)
  o = o or { args = {} }
  setmetatable(o, self)
  self.__index = self
  return o
end

function AstConst:new(o)
  o = o or {}
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
    return evaluate(ast.args[1].values[1])
  else
    assert(false)
  end
end

local function apply_const(ast)
  return ast.value
end

local function parse(tokens)
  assert(#tokens > 2, 'S-astession too small')
  assert(tokens[1] == '(', 'expected LPAREN but got ' .. tokens[1])
  assert(tokens[#tokens] == ')', 'expected RPAREN but got ' .. tokens[#tokens])

  -- Check the first token after LPAREN
  local is_list = tonumber(tokens[2])

  if is_list then
    local ast = AstList:new()

    -- Remove parens
    local tokens_trimmed = { table.unpack(tokens, 2, #tokens - 1) }

    local i, argc = 1, 1
    while i <= #tokens_trimmed do
  
      if tokens_trimmed[i] == '(' then
  
        local j, paren = i + 1, 0
        while j < #tokens_trimmed do
          if tokens_trimmed[j] == ')' then
            if paren == 0 then break end
            paren = paren - 1
          elseif tokens_trimmed[j] == '(' then
            paren = paren + 1
          end
          j = j + 1
        end
  
        table.insert(ast.values, argc, parse({ table.unpack(tokens_trimmed, i, j) }))
        i = j + 1
  
      else
        local const = AstConst:new({ value = tonumber(tokens_trimmed[i]) })
        table.insert(ast.values, argc, const)
        i = i + 1
      end
  
      argc = argc + 1
    end
    return ast
  else
    local ast = AstPrimitive:new()
    ast.func = tokens[2]
  
    -- Remove all tokens except args
    local tokens_trimmed = { table.unpack(tokens, 3, #tokens - 1) }
  
    local i, argc = 1, 1
    while i <= #tokens_trimmed do
  
      if tokens_trimmed[i] == '(' then
  
        local j, paren = i + 1, 0
        while j < #tokens_trimmed do
          if tokens_trimmed[j] == ')' then
            if paren == 0 then break end
            paren = paren - 1
          elseif tokens_trimmed[j] == '(' then
            paren = paren + 1
          end
          j = j + 1
        end
  
        table.insert(ast.args, argc, parse({ table.unpack(tokens_trimmed, i, j) }))
        i = j + 1
  
      else
        local const = AstConst:new({ value = tonumber(tokens_trimmed[i]) })
        table.insert(ast.args, argc, const)
        i = i + 1
      end
  
      argc = argc + 1
    end
    return ast
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
  if ast.__type == 'AstPrimitive' then
    return apply_primitive(ast)
  elseif ast.__type == 'AstConst' then
    return apply_const(ast)
  elseif ast.__type == 'AstList' then
    return ast
  else
    assert(false)
  end
end

local function interpret(S)
  return evaluate(parse(tokenize(S)))
end

--print(interpret('(* (+ (// (- 16 2) 2) 3) 3)'))
print(interpret('(car (1 2 3))'))
