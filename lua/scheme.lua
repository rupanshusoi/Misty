function eval_arithmetic(expr)
  if expr.func == 'add1' then
    return expr.arg1 + expr.arg2
  end
end

--[[
function parse(tokens)
  assert(#tokens > 0)
  if tokens[1] == '(' then
    assert(tokens[#tokens] == ')')

    tokens_trimmed = { table.unpack(tokens, 2, #tokens - 1) }
    expr = {}

    idx = 1
    while idx <= #tokens_trimmed do
      if idx == 1 then
        expr.func = tokens_trimmed[idx]
        idx = idx + 1
      else
        if tokens_trimmed[idx] == '(' then
          idx_closep = 0
          for i = idx + 1, #tokens_trimmed do
            if tokens_trimmed[i] == ')' then
              idx_closep = i
              break
            end
          end
          assert(idx_closep ~= 0)
          expr['arg' .. tostring(idx - 1)] = parse({ table.unpack(tokens_trimmed, idx, idx_closep) })
          idx = idx_closep + 1
        else
          expr['arg' .. tostring(idx - 1)] = tonumber(tokens_trimmed[idx])
          idx = idx + 1
        end
      end
    end
    return expr
  else
    assert(#tokens == 1)
    return tonumber(tokens[1])
  end
end
--]]
    
function parse(tokens)
  print 'parse called'
  assert(#tokens > 2)
  assert(tokens[1] == '(')
  assert(tokens[#tokens] == ')')

  expr = {}
  expr.func = tokens[2]

  -- Remove all tokens except args
  tokens_trimmed = { table.unpack(tokens, 3, #tokens - 1) }

  i = 1
  while i <= #tokens_trimmed do
    if tokens_trimmed[i] == '(' then
      j = i
      while j < #tokens_trimmed do
        if tokens_trimmed[j] == '(' then
          break
        end
        j = j + 1
      end
      expr['arg' .. tostring(i)] = parse({ table.unpack(tokens_trimmed, i, j) })
      i = j + 1
    else
      expr['arg' .. tostring(i)] = tonumber(tokens_trimmed[i])
      i = i + 1
    end
  end

  return expr
end

function tokenize(S)
  S, _ = S:gsub('%(', ' ( ')
  S, _ = S:gsub('%)', ' ) ')
  tokens = {}
  for i in S:gmatch('%S+') do
    table.insert(tokens, i)
  end
  return tokens
end

function meaning(S, env)
  expr = parse(tokenize(S))
  for k,v in pairs(expr) do
    print(k .. ' ' .. tostring(v))
  end
end

function evaluate(S)
  return meaning(S, {})
end

--evaluate('(+ 2 3 4 5)')
evaluate('(+ 2 (+ 4 5))')
