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

function parser.parse_list(tokens)
  local ast = types.AstList:new()

  -- Remove parens
  local tokens_trimmed = { table.unpack(tokens, 2, #tokens - 1) }

  local i = 1
  while i <= #tokens_trimmed do

    if tokens_trimmed[i] == '(' then
      local closep = parser.find_closep(tokens_trimmed, i)
      table.insert(ast.values, parser.parse({ table.unpack(tokens_trimmed, i, closep) }, true))
      i = closep + 1

    else
      table.insert(ast.values, types.AstAtom:new({ value = tokens_trimmed[i] }))
      i = i + 1

    end
  end
  return ast
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

function parser.parse(tokens, is_quoted)
  assert(#tokens > 2, 'S-expression too small')
  assert(tokens[1] == '(', 'expected LPAREN but got: ' .. tokens[1])
  assert(tokens[#tokens] == ')', 'expected RPAREN but got: ' .. tokens[#tokens])

  if is_quoted then
    return parser.parse_list(tokens)

  else
    if tokens[2] == 'quote' then
      return parser.parse_list({ table.unpack(tokens, 3, #tokens - 1) }) 

    else
      return parser.parse_primitive(tokens)

    end
  end
end

return parser
