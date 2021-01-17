local types = {}

types.AstPrimitive = { __type = 'AstPrimitive' }
types.AstList      = { __type = 'AstList'      }
types.AstAtom      = { __type = 'AstAtom'      }

function types.AstPrimitive:new(o)
  o = o or { args = {} }
  setmetatable(o, self)
  self.__index = self
  return o
end

function types.AstList:new(o)
  o = o or { values = {} }
  setmetatable(o, self)
  self.__index = self
  return o
end

function types.AstAtom:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

return types
