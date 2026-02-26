-- # core src

local src = {}
src.Libs = require('@self/interface/src_library'):Libs()
src.Mapping = require('@self/mapping')

setmetatable(src, {__index=src.Libs.Hexagon:Source()})
return src