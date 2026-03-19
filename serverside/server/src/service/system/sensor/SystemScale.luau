local main = require('../../../');
local components = require('../../../interface/src_components')
local WorldsService = main.Core.Services.WorldsService()
local CodeUtility = main.Libs.CodeUtility
local Mapping = main.Mapping

local private = {};
local interface = {};

local model = components.property.Model()
local scale = components.parameter.Scale()

interface.Service = main.Core.Classes.SadSystemService().new({
	Name = script.Name;
	TargetWorld = WorldsService.Service:GetWorld('game.world')
})

function private.main (World)
	local Service = interface.Service
	
	scale:DoCatchFromWorld(World, function(ComScale)
		private.fetch_scale(World, ComScale)
	end)
end

function private.fetch_scale (World, ComScale: typeof(scale.Value))
	model:DoCatchFromWorld(World, function(Component: { Path: string, Source: string }) 
		local this = CodeUtility.GetInstanceFrom(Component.Path) :: Model?
		if this then
			ComScale.Previous = ComScale.Value
			ComScale.Value = this:GetScale()
		end
	end)
end

interface.Service:DoWhileActive():ConnectParallel(function(deltaTime: number, NewCycle: boolean) 
	local TargetWorld = interface.Service.TargetWorld
	if WorldsService.Service:IsItWorld(TargetWorld) then
		TargetWorld:DoForWorlds(private.main)
	end
end)

return interface