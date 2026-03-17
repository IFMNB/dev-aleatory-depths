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
	
	scale:DoCatchFromWorld(World, function(Component1: { Value: number })
		local PhaseLog = Service:DoPhaseLog()
		PhaseLog.Insert(1, true)
		model:DoCatchFromWorld(World, function(Component2: { Path: string, Source: string }) 
			PhaseLog.Insert(2, true)
			local this = CodeUtility.GetInstanceFrom(Component2.Path) :: Model?
			if this then
				task.synchronize()
				Component1.Value = this:GetScale()
				task.desynchronize()
			end
			PhaseLog.Insert(3, this ~= nil)
		end)
		
		PhaseLog.EndLog(World.Identity)
	end)
end

interface.Service:DoWhileActive():ConnectParallel(function(deltaTime: number, NewCycle: boolean) 
	local TargetWorld = interface.Service.TargetWorld
	if WorldsService.Service:IsItWorld(TargetWorld) then
		TargetWorld:DoForWorlds(private.main)
	end
end)

return interface