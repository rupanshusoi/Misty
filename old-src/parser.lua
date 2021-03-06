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

function parser.expand_quotes(tokens)
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

  if #tokens_trimmed == 0 then
    return ast
  end

  i = 1
  while i <= #tokens_trimmed do

    if tokens_trimmed[i] == '(' then
      local closep = parser.find_closep(tokens_trimmed, i)
      table.insert(ast.values, parser.parse_list{ table.unpack(tokens_trimmed, i, closep) } )
      i = closep + 1

    else
      table.insert(ast.values, types.AstAtom:new{ value = tokens_trimmed[i] } )
      i = i + 1

    end
  end
  return ast
end

function parser.parse_cond_line(list)
  assert(#list.values == 2, 'ill-formed cond-line')

  local ast = types.AstCondLine:new()
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

function parser.parse_lambda(list)
  assert(#list.values == 3, 'ill-formed lambda expression')

  local ast = types.AstLambda:new()
  ast.formals = list.values[2]
  ast.body = parser.main(list.values[3])

  return ast
end

function parser.parse_application(list)
  -- There are 3 cases here:
  -- 1. (primitive args)
  -- 2. (non-primitive args)
  -- 3. ((lambda ...) args)
  -- Let us parse cases 1 & 2 the same way,
  -- and then, during evaluation, we try will try to evaluate every
  -- application as a primitive first, and if that fails only then 
  -- we try to evaluate as a non-primitive. This will also save us from
  -- having to create a list of supported primitives to check against
  -- here, which I really don't want to do.

  if list.values[1].__type == 'AstList' then
    local ast = types.AstPrimitive:new()
    ast.func = parser.parse_lambda(list.values[1])

    for i = 2, #list.values do
      table.insert(ast.args, parser.main(list.values[i]))
    end

    return ast
  else
    return parser.parse_primitive(list)
  end
end

function parser.main(list)
  if list.__type == 'AstAtom' then
    if tonumber(list.value) then return tonumber(list.value)

    elseif (list.value == 'else') or (list.value == '#t') then
      return types.AstAtom:new{ value = '#t' }

    elseif (list.value == '#f') then
      return list

    else
      return types.AstIdentifier:new{ name = list.value }

    end

  end

  if list.values[1].value == 'quote' then
    assert(#list.values == 2, 'can not quote more than one argument')
    return types.AstPrimitive:new{
      func = types.AstAtom:new{ value = 'quote' },
      args = { list.values[2] },
    }

  elseif list.values[1].value == 'cond' then
    return parser.parse_cond(list)

  elseif list.values[1].value == 'lambda' then
    -- We should only reach here when parsing (define id (lambda ...))
    return parser.parse_lambda(list)

  else
    return parser.parse_application(list)

  end
  assert(false)
end

function parser.parse(S)
  -- Assume outermost level is a list
  return parser.main(parser.parse_list(parser.expand_quotes(parser.tokenize(S))))
end

return parser
