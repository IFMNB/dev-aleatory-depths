local main = require('../../../');
local components = require('../../../interface/src_components')

local WorldsService = main.Core.Services.WorldsService()

local model = components.Model()

local private = {};
local interface = {};

type System = typeof(interface.Service)
type World = typeof(interface.Service.TargetWorld)
type SharedWorld = typeof(interface.Service.TargetWorld)

interface.Service = main.Core.Classes.SadSystemService().new({
	Name = script.Name;
	TargetWorld = WorldsService.Service:GetWorld('game.world');
});

function private.Subact (Component)
	if Component.IsTemporal then
		local target = main.Libs.RbxUtility.FromPath(Component.Path)
		if target then
			target.Parent = workspace
			Component.IsTemporal = false
			Component.Path = target:GetFullName()
		end
	end
end



interface.Service:DoWhileActive():ConnectParallel(function(deltaTime: number, NewCycle: boolean)
	local TargetWorld = interface.Service.TargetWorld;
	TargetWorld:DoForWorlds(function (World)
		local Service = interface.Service
		local PhaseLog = Service:DoPhaseLog()
		
		model:DoCatchFrom(World, function(Component: { IsTemporal: boolean, Path: string }) 
			if not Component.IsTemporal then return end
			local this = main.Libs.RbxUtility.FromPath(Component.Path) :: PVInstance?
			if this then
				PhaseLog.Insert(1,true)
				SharedTable.update(Component::any, 'IsTemporal', function(arg) 
					if arg == true then
						return false
					end
					
					return main.Mapping.Exception.ParallelConditionException:Throw()
				end)
				
				
				if main.Libs.CodeUtility.IsParallelContext() then
					task.synchronize()
				end	
				
				local copy = this:Clone()
				copy.Parent = workspace
				Component.Path = copy:GetFullName()
			end
		end)
		
		PhaseLog.EndLog(World.Identity)
	end)
end)

return interface