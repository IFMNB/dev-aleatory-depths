local core = require(game.ReplicatedStorage.core)
local interface = {}

interface.Classes = setmetatable({}, {__index=core.Classes})
interface.Abstracts = setmetatable({}, {__index=core.Abstracts})
interface.Interfaces = setmetatable({}, {__index=core.Interfaces})

function interface.Classes.SadMap ()
	return require('../storage/classes/SadMap').SadMap
end

function interface.Classes.SadConfigSnapshot ()
	return require('../storage/classes/SadConfigSnapshot').SadConfigSnapshot
end


return interface