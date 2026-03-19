local main = require('../../../');
local components = require('../../../interface/src_components')
local WorldsService = main.Core.Services.WorldsService()
local CodeUtility = main.Libs.CodeUtility
local Mapping = main.Mapping

local model = components.property.Model()
local velocity = components.parameter.Velocity()

local private = {}
local interface = {}

function private.main (World)
	local Service = interface.Service
	
	velocity:DoCatchFromWorld(World, function(Component) 
		private.fetch_velocity(World, Component)
	end)
end

function private.fetch_velocity (World, ComVel: typeof(velocity.Value))
	model:DoCatchFromWorld(World, function(ComModel: { Path: string, Source: string }) 
		local primary : PVInstance?
		local this = CodeUtility.GetInstanceFrom(ComModel.Path) :: Model?
		
		if this then
			primary = this.PrimaryPart
			if primary then
				ComVel.Previous = ComVel.Value
				ComVel.Value = primary.AssemblyLinearVelocity
			end
		end
	end)
end

interface.Service = main.Core.Classes.SadSystemService().new({
	Name = script.Name;
	TargetWorld = WorldsService.Service:GetWorld('game.world')
})

interface.Service:DoWhileActive():ConnectParallel(function (delta, first)
	local TargetWorld = interface.Service.TargetWorld
	if WorldsService.Service:IsItWorld(TargetWorld) then
		TargetWorld:DoForWorlds(private.main)
	end
end)

return interface