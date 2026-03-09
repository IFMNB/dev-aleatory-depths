local path = script.Parent.Parent.storage.components
local components = table.freeze({
	Health = function ()
		return require(path.health)
	end,
})

return components