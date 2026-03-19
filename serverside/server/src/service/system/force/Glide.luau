local main = require('../../../');
local components = require('../../../interface/src_components')
local WorldsService = main.Core.Services.WorldsService()
local CodeUtility = main.Libs.CodeUtility
local Mapping = main.Mapping

local private = {};
local interface = {};

local glide = components.effect.Glide()
local floor = components.parameter.Floor()
local velocity = components.parameter.Velocity()
local height = components.parameter.Height()
local mass = components.property.Mass()

interface.Service = main.Core.Classes.SadSystemService().new({
	Name = script.Name;
	TargetWorld = WorldsService.Service:GetWorld('game.world')
})

function private.main (World)
	local Service = interface.Service
	
end

interface.Service:DoWhileActive():ConnectParallel(function(deltaTime: number, NewCycle: boolean) 
	local TargetWorld = interface.Service.TargetWorld
	if WorldsService.Service:IsItWorld(TargetWorld) then
		TargetWorld:DoForWorlds(private.main)
	end
end)

return interface