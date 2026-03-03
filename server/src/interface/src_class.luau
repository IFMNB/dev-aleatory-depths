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

function interface.Classes.SadCharacterReference ()
	return require('../storage/classes/SadCharacterReference').SadCharacterReference
end

function interface.Classes.SadPlayableCharacter () 
	return require('../storage/classes/__SadAbstractCharacter/SadPlayeableCharacter').SadPlayableCharacter
end

function interface.Abstracts.SadAbstractCharacter ()
	return require('../storage/classes/__SadAbstractCharacter').__SadAbstractCharacter
end

return interface