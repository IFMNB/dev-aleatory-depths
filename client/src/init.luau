local core = require(game.ReplicatedStorage.core)
local src = setmetatable({}, {__index=core:Source()})
src.Core = core

return src