local path = script.Parent.Parent.storage.characters
local characters = table.freeze({
	Fortuna = function ()
		return require(path.Fortuna)
	end,
})

return characters