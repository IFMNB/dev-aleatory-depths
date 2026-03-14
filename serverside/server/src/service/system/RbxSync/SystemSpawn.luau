local main = require('../../../');
local components = require('../../../interface/src_components')
local WorldsService = main.Core.Services.WorldsService()
local CollectionService = game:GetService('CollectionService')

local private = {};
local interface = {};

local model = components.property.Model()
local spawn = components.action.Spawn()

interface.Service = main.Core.Classes.SadSystemService().new({
	Name = script.Name;
	TargetWorld = WorldsService.Service:GetWorld('game.world');
})

function private.Action (World)
	local Service = interface.Service
	local TargetWorld = Service.TargetWorld
	local PhaseLog = Service:DoPhaseLog()
	
	spawn:DoCatchFromWorld(World, function(Component1)
		TargetWorld.RemComponent(World, spawn.Name)
		
		local IsProcessed = model:DoCatchFromWorld(World, function(Component2: { Path: string, Source: string })
			PhaseLog.Insert(1,true)
			if Component2.Path == '' then
				local TargetPath = main.Libs.RbxUtility.FromPath(Component1.ToPath)
				local this = main.Libs.RbxUtility.FromPath(Component2.Source) :: PVInstance?
				if this then
					PhaseLog.Insert(2, true)
					PhaseLog.Insert(3, TargetPath ~= nil)
					local target = TargetPath or workspace
					
					if main.Libs.CodeUtility.IsParallelContext() then
						task.synchronize()
					end
					
					local copy = this:Clone()
					copy.Parent = target
					main.Mapping.Exception.ParallelConditionException:Assert(TargetWorld.DoUpdateComponent(World, model.Name, 'Path', function(old, current) 
						if current == old then
							return copy:GetFullName()
						end
						return current
					end))
				end
			end
		end)
		
		if not IsProcessed then
			main.Mapping.Exception.ParallelConditionException:Throw()
		end
		
	end)
end

interface.Service:DoWhileActive():ConnectParallel(function(deltaTime: number, NewCycle: boolean) 
	local TargetWorld = interface.Service.TargetWorld
	TargetWorld:DoForWorlds(private.Action)
end)

return interface