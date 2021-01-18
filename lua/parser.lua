local types = require('types')

local parser = {}

function parser.tokenize(S)
  local S, _ = S:gsub('%(', ' ( ')
  S, _ = S:gsub('%)', ' ) ')
  S, _ = S:gsub("'", " ' ")

  local tokens = {}
  for i in S:gmatch('%S+') do
    table.insert(tokens, i)
  end

  return tokens
end

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

function parser.expand_quote(tokens)
  -- Expand 'l --> (quote l)
  local i = 1
  while i < #tokens do
    if tokens[i] == "'" then
      if tokens[i + 1] == '(' then
        -- List
        tokens[i] = 'quote'
        table.insert(tokens, i, '(')

        local closep = parser.find_closep(tokens, i + 2)
        table.insert(tokens, closep + 1, ')')

        i = closep + 2
      else
        -- Atom
        tokens[i] = 'quote'
        table.insert(tokens, i, '(')
        table.insert(tokens, i + 3, ')')

        i = i + 4
      end
    else
      i = i + 1
    end
  end

  return tokens
end

function parser.parse_list(tokens)
  local ast = types.AstList:new()

  -- Remove outermost parens
  local tokens_trimmed = { table.unpack(tokens, 2, #tokens - 1) }

  i = 1
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

function parser.parse_cond_line(list)
  local ast = types.AstCondLine:new()

  assert(#list.values == 2, 'ill-formed cond-line')
  ast.cond = parser.main(list.values[1])
  ast.stat = parser.main(list.values[2])

  return ast
end

function parser.parse_cond(list)
  local ast = types.AstCond:new()

  for i = 2, #list.values do
    table.insert(ast.cond_lines, parser.parse_cond_line(list.values[i])) 
  end

  return ast
end

function parser.parse_primitive(list)
  local ast = types.AstPrimitive:new()
  ast.func = list.values[1]

  for i = 2, #list.values do
    table.insert(ast.args, parser.main(list.values[i]))
  end

  return ast
end

function parser.main(list)
  if list.__type == 'AstAtom' then
    if tonumber(list.value) then return tonumber(list.value)
    elseif (list.value == 'else') or (list.value == '#t') then
      return types.AstAtom:new({ value = '#t' })
    elseif (list.value == '#f') then
      return list
    else assert(false) end
  end

  if list.values[1].value == 'quote' then
    assert(#list.values == 2, 'can not quote more than one argument')
    return types.AstPrimitive:new({
      func = types.AstAtom:new({ value = 'quote' }),
      args = list.values[2],
    })
  elseif list.values[1].value == 'cond' then
    return parser.parse_cond(list)
  else
    return parser.parse_primitive(list)
  end
  assert(false)
end

function parser.parse(tokens)
  -- Assume outermost level is a list
  return parser.main(parser.parse_list(parser.expand_quote(tokens)))
end

return parser
