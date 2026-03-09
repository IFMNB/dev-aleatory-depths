local path = script.Parent.Parent.storage.components
local components = table.freeze({
	HealthComponent = function ()
		return require(path.HealthComponent)
	end,
})

return components