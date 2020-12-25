import math
import operator as op

# Type Implementations
Symbol = str
Number = (int, float)
Atom = (Symbol, Number)
List = list
Exp = (Atom, List)
Env = dict

def tokenize(chars: str) -> list:
    return chars.replace('(', ' ( ').replace(')', ' ) ').split()

def read_from_tokens(tokens: list) -> Exp:
  if (len(tokens) == 0):
    raise SyntaxError('unexpected EOF')
  token = tokens.pop(0)
  if token == '(':
    L = []
    while tokens[0] != ')':
      L.append(read_from_tokens(tokens))
    tokens.pop(0)
    return L
  elif token == ')':
    raise SyntaxError('unexpected')
  else:
    return atom(token)

def atom(token: str) -> Atom:
  try:
    return int(token)
  except ValueError:
    try:
      return float(token)
    except ValueError:
      return Symbol(token)

def parse(program: str) -> Exp:
  return read_from_tokens(tokenize(program))

def standard_env() -> Env:
  env = dict()
  env.update(vars(math))
  env.update({
    '+': op.add,
    '-': op.sub,
    '*': op.mul,
    '/': op.truediv,
    'expt': pow,
    'eq?': op.is_,
    'equal?': op.eq,
    'car': lambda x: x[0],
    'cdr': lambda x: x[1:],
    'cons': lambda x, y: [x] + y,
    'null?': lambda x: x == [],
    'length': len,
    'number?': lambda x: isinstance(x, Number),
    'symbol?': lambda x: isinstance(x, Symbol),
  })
  return env

global_env = standard_env()
