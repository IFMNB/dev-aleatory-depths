local path = script.Parent.Parent.storage.components
local components = table.freeze({
	Health = function ()
		return require(path.health)
	end,
	Model = function ()
		return require(path.model)
	end,
	Position= function ()
		return require(path.position)
	end,
	Rotation = function ()
		return require(path.rotation)
	end,
	Velocity = function ()
		return require(path.velocity)
	end,
	Lifeform = function ()
		return require(path.lifeform)
	end,
	Height = function ()
		return require(path.height)
	end,
	-- Физическая форма (может быть PrimaryPart модели)
	Form = function ()
		return require(path.form)
	end,
	
})

return components