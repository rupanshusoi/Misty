local types = {}

types.AstPrimitive = { __type = 'AstPrimitive' }
types.AstList      = { __type = 'AstList'      }
types.AstAtom      = { __type = 'AstAtom'      }
types.AstCond      = { __type = 'AstCond'      }
types.AstCondLine  = { __type = 'AstCondLine'  }

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

function types.AstCond:new(o)
  o = o or { cond_lines = {} }
  setmetatable(o, self)
  self.__index = self
  return o
end

function types.AstCondLine:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

return types
