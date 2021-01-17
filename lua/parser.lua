local types = require('types')

local parser = {}

function parser.find_closep(tokens, openp)
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

--[[
function parser.parse_primitive(tokens)
  local ast = types.AstPrimitive:new()
  ast.func = tokens[2]

  local tokens_trimmed = { table.unpack(tokens, 3, #tokens - 1) }

  local i = 1
  while i <= #tokens_trimmed do

    if tokens_trimmed[i] == '(' then
      local closep = parser.find_closep(tokens_trimmed, i)
      table.insert(ast.args, parser.parse({ table.unpack(tokens_trimmed, i, closep) }))
      i = closep + 1

    elseif tonumber(tokens_trimmed[i]) then
      table.insert(ast.args, tonumber(tokens_trimmed[i]))
      i = i + 1

    else
      -- Must be an atom
      table.insert(ast.args, types.AstAtom:new({ value = tokens_trimmed[i] }))
      i = i + 1

    end
  end
  return ast
end
--]]

function parser.parse_list(tokens)
  local ast = types.AstList:new()

  -- Remove outermost parens
  local tokens_trimmed = { table.unpack(tokens, 2, #tokens - 1) }

  local i = 1
  while i <= #tokens_trimmed do

    if tokens_trimmed[i] == '(' then
      local closep = parser.find_closep(tokens_trimmed, i)
      table.insert(ast.values, parser.parse_list({ table.unpack(tokens_trimmed, i, closep) }))
      i = closep + 1

    else
      table.insert(ast.values, types.AstAtom:new({ value = tokens_trimmed[i] }))
      i = i + 1

    end
  end
  return ast
end

function parser.parse_cond(tokens)
  local tokens_trimmed = { table.unpack(tokens, 3, #tokens - 1) }

  local i = 1
  while i < #tokens_trimmed do
    
  end
end

function parser.tokenize(S)
  local S, _ = S:gsub('%(', ' ( ')
  S, _ = S:gsub('%)', ' ) ')

  local tokens = {}
  for i in S:gmatch('%S+') do
    table.insert(tokens, i)
  end

  return tokens
end

--[[
function parser.parse(tokens, is_quoted)
  assert(#tokens > 2, 'S-expression too small')
  assert(tokens[1] == '(', 'expected LPAREN but got: ' .. tokens[1])
  assert(tokens[#tokens] == ')', 'expected RPAREN but got: ' .. tokens[#tokens])

  if is_quoted then
    return parser.parse_list(tokens)

  else
    if tokens[2] == 'quote' then
      return parser.parse_list({ table.unpack(tokens, 3, #tokens - 1) }) 

    elseif tokens[2] == 'cond' then
      return parser.parse_cond(tokens)

    else
      return parser.parse_primitive(tokens)

    end
  end
end
--]]

function parser.parse_primitive(list)
  local ast = types.AstPrimitive:new()
  ast.func = list.values[1]

  for arg = 2, #list.values do
    ast.args[arg - 1] = parser.main(list.values[arg])
  end

  return ast
end

function parser.main(list)
  if list.__type == 'AstAtom' then
    if tonumber(list.value) then return tonumber(list.value)
    else assert(false) end
  end

  if list.values[1].value == 'quote' then
    assert(#list.values == 2, 'can not quote more than one argument')
    return list.values[2]
  else
    return parser.parse_primitive(list)
  end
  assert(false)
end

function parser.parse(tokens)
  -- Assume outermost level is a list
  return parser.main(parser.parse_list(tokens))
end

return parser
