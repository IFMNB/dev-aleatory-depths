local services = script.Parent.Parent.service

local system = services.system
local physic = system.physic
local sensors = system.sensor
local Workspace = system.workspace

local net = services.net
local Game = services.game

local src = table.freeze(setmetatable({
	Net = table.freeze({
		OwnerService = function ()
			return require(net.NetOwnerService)
		end,
		IOService = function ()
			return require(net.NetInputService)
		end,
		CoordinateService = function ()
			return require(net.NetCoordinateService)
		end,
	});
	
	Game = table.freeze({
		MapService = function ()
			return require(Game.GameMapService)
		end,
		StunService = function ()
			return require(Game.GameStunService)
		end,
	});
	
	
	System = table.freeze({
		Physic = table.freeze({
			Rotation = function ()
				return require(physic.SystemRotation)
			end,
			Position = function ()
				return require(physic.SystemPosition)
			end,
			Velocity = function ()
				return require(physic.SystemVelocity)
			end,
			Gravity = function ()
				return require(physic.SystemGravity)
			end,
	
		});
		Sensors = table.freeze({
			Scale = function ()
				return require(sensors.SystemScale)
			end,
			Roof = function ()
				return require(sensors.SystemRoof)
			end,
			Floor = function ()
				return require(sensors.SystemFloor)
			end,
			
			Mass = function ()
				return require(sensors.SystemMass)
			end
		});
		Workspace = table.freeze({
			Spawn = function ()
				return require(Workspace.SystemSpawn)
			end,
		});
		

	});
	
}, {__index=require(game.ReplicatedStorage.core).Services}))

return src