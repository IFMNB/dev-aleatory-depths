local main = require('../../');

local WorldsService = main.Core.Services.WorldsService()
local components = require('../../interface/src_components')

local position = components.Position()
local rotation = components.Rotation()
local surface = components.Surface()

local private = {};
local interface = {};

type System = typeof(interface.Service)
type World = typeof(interface.Service.TargetWorld)
type SharedWorld = typeof(interface.Service.TargetWorld:GetShared())

interface.Service = main.Core.Classes.SadSystemService().new({
	Name = script.Name;
	TargetWorld = WorldsService.Service:GetWorld('game.world');
});

function private.ActionGlide (World: World)
	local Service = interface.Service
	local Phase1, Phase2, Phase3 = false, false,false
	
	Phase1 = surface:DoCatchFrom(World, function(Component1: { Value: RaycastResult? }) 
		Phase2 = position:DoCatchFrom(World, function(Component2: { Value: Vector3 }) 
			local RotationVectorDown = Vector3.new(0,-1,0)
			local Position = Component2.Value
			
			Phase3 = rotation:DoCatchFrom(World, function(Component3: { Look: Vector3, Right: Vector3, Up: Vector3 }) 
				RotationVectorDown = -Component3.Up
			end)
			
			
		end)
	end)

	
	if not Phase1 then
		if Service:IsLogActive() then
			Service:PrintLog(string.format('Failed Phase1, %s', World.Identity))
		end
		return
	end
	
	if not Phase2 then
		if Service:IsLogActive() then
			Service:PrintLog(string.format('Failed Phase2, %s', World.Identity))
		end
		return
	end
	
	if not Phase3 then
		if Service:IsLogActive() then
			Service:PrintLog(string.format('Failed Phase3, result can be incorrect, %s', World.Identity))
		end
		return
	end
	
	if Service:IsLogActive() then
		Service:PrintLog(`success`)
	end
end

interface.Service:DoWhileActive(function() 
	local TargetWorld = interface.Service.TargetWorld;
	TargetWorld:DoForShared(function(RawWorld) 
		position:DoCatchFrom(RawWorld, function(Component2)
			
		end)
	end)
end)

return interface