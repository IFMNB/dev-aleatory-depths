local path = script.Parent.Parent.storage.components

local property = path.property
local parameter = path.parameter
local action = path.action
local effect = path.effect

local components = table.freeze({
	property = table.freeze({
		Lifeform = function ()
			return require(property.lifeform)
		end,
		Model = function ()
			return require(property.model)
		end,
		Mass = function ()
			return require(property.mass)
		end,
		Player = function ()
			return require(property.player)
		end,
		CustomPhysics = function ()
			return require(property.physic)
		end,
	});
	parameter = table.freeze({
		Health = function ()
			return require(parameter.health)
		end,
		Position= function ()
			return require(parameter.position)
		end,
		Rotation = function ()
			return require(parameter.rotation)
		end,
		Velocity = function ()
			return require(parameter.velocity)
		end,
		Height = function ()
			return require(parameter.height)
		end,
		Floor = function ()
			return require(parameter.floor)
		end,
		Roof = function ()
			return require(parameter.roof)
		end,
		Scale = function ()
			return require(parameter.scale)
		end,
	});
	action = table.freeze({
		Spawn = function ()
			return require(action.spawn)
		end,
		Teleport = function ()
			return require(action.teleport)
		end
	});
	effect = table.freeze({
		Gravity = function ()	
			return require(effect.gravity)
		end,
	});

	

	
})

return components