local function eval_arithmetic(expr)
  if expr.func == 'add1' then
    return expr.arg1 + expr.arg2
  end
end

local function parse(tokens)
  assert(#tokens > 2)
  assert(tokens[1] == '(')
  assert(tokens[#tokens] == ')')

  local expr = {}
  expr.func = tokens[2]

  -- Remove all tokens except args
  local tokens_trimmed = { table.unpack(tokens, 3, #tokens - 1) }

  local i, argc = 1, 1
  while i <= #tokens_trimmed do
    if tokens_trimmed[i] == '(' then
      local j, paren = i + 1, 0
      while j < #tokens_trimmed do
        if tokens_trimmed[j] == ')' then
          if paren == 0 then
            break
          end
          paren = paren - 1
        elseif tokens_trimmed[j] == '(' then
          paren = paren + 1
        end
        j = j + 1
      end
      expr['arg' .. tostring(argc)] = parse({ table.unpack(tokens_trimmed, i, j) })
      i = j + 1
    else
      expr['arg' .. tostring(argc)] = tonumber(tokens_trimmed[i])
      i = i + 1
    end
    argc = argc + 1
  end

  return expr
end

local function tokenize(S)
  S, _ = S:gsub('%(', ' ( ')
  S, _ = S:gsub('%)', ' ) ')
  local tokens = {}
  for i in S:gmatch('%S+') do
    table.insert(tokens, i)
  end
  return tokens
end

local function meaning(S, env)
  local expr = parse(tokenize(S))

  print(expr.arg1.arg1.arg2)
end

local function evaluate(S)
  return meaning(S, {})
end

--evaluate('(+ 2 3 4 5)')
evaluate('(+ (- (+ 5 6) 4) (+ 1 2))')
