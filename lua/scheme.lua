-- Add types

local AstPrimitive = { __type = 'AstPrimitive' }
local AstConst =     { __type = 'AstConst'     }

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

local function apply_primitive(expr)
  if expr.func == '+' then
    return evaluate(expr.args[1]) + evaluate(expr.args[2])
  elseif expr.func == '-' then
    return evaluate(expr.args[1]) - evaluate(expr.args[2])
  elseif expr.func == '*' then
    return evaluate(expr.args[1]) * evaluate(expr.args[2])
  elseif expr.func == '//' then
    return evaluate(expr.args[1]) // evaluate(expr.args[2])
  end
end

local function apply_const(ast)
  return ast.value
end

local function parse(tokens)
  assert(#tokens > 2, 'S-expression too small')
  assert(tokens[1] == '(', 'expected LPAREN but got ' .. tokens[1])
  assert(tokens[#tokens] == ')', 'expected RPAREN but got ' .. tokens[#tokens])

  local expr = AstPrimitive:new()
  expr.func = tokens[2]

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

      table.insert(expr.args, argc, parse({ table.unpack(tokens_trimmed, i, j) }))
      i = j + 1

    else
      local const = AstConst:new({ value = tonumber(tokens_trimmed[i]) })
      table.insert(expr.args, argc, const)
      i = i + 1
    end

    argc = argc + 1
  end

  return expr
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

function evaluate(ast)
  if ast.__type == 'AstPrimitive' then
    return apply_primitive(ast)
  elseif ast.__type == 'AstConst' then
    return apply_const(ast)
  else
    assert(false)
  end
end

local function interpret(S)
  return evaluate(parse(tokenize(S)))
end

print(interpret('(* (+ (// (- 16 2) 2) 3) 3)'))
