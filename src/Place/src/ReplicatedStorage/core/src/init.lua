-- # core src

local Library = require('@self/interface/src_library'):Libs()
local Hexagon_Source = Library.Hexagon:Source()
local src = {}
setmetatable(src, {__index=Hexagon_Source})

src.Libs = Library
src.Mapping = require('@self/mapping')
src.Abstract = setmetatable({}, {__index=Hexagon_Source.Abstract})

return src