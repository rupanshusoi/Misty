local function eval_arithmetic(expr)
  if type(expr) == 'table' then
    if expr.func == '+' then
      return eval_arithmetic(expr.arg1) + eval_arithmetic(expr.arg2)
    elseif expr.func == '-' then
      return eval_arithmetic(expr.arg1) - eval_arithmetic(expr.arg2)
    elseif expr.func == '*' then
      return eval_arithmetic(expr.arg1) * eval_arithmetic(expr.arg2)
    elseif expr.func == '//' then
      return eval_arithmetic(expr.arg1) // eval_arithmetic(expr.arg2)
    end
  elseif type(expr) == 'number' then
    return expr
  else
    assert(false)
  end
end

local function parse(tokens)
  assert(#tokens > 2, 'S-expression too small')
  assert(tokens[1] == '(', 'expected LPAREN but got ' .. tokens[1])
  assert(tokens[#tokens] == ')', 'expected RPAREN but got ' .. tokens[#tokens])

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
          if paren == 0 then break end
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
  local ast = parse(tokenize(S))
  return eval_arithmetic(ast)
end

local function evaluate(S)
  return meaning(S, {})
end

print(evaluate('(* (+ (// (- 16 2) 2) 3) 3)'))
