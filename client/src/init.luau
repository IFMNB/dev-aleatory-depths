local core = require(game.ReplicatedStorage.core)
local src = setmetatable({}, {__index=core:Source()})
src.Core = core
src.ClientLibs = require('@self/interface/src_libs')

return src