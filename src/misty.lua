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

local function eval(list)
  if tonumber(list) then
    return tonumber(list)
  end

  local func = list[1]
  if func == '+' then
    return eval(list[2]) + eval(list[3])
  elseif func == '*' then
    return eval(list[2]) * eval(list[3])
  elseif func == 'car' then
    return eval(list[2])[1]
  elseif func == 'cdr' then
    return { table.unpack(eval(list[2]), 2) }
  elseif func == 'cons' then
    return { eval(list[2]), table.unpack(eval(list[3])) }
  elseif func == 'quote' then
    return list[2]
  end

end

function Misty.run(source)
  return eval(parse(tokenize(source)))
end

return Misty
