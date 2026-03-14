local main = require('../../../');
local components = require('../../../interface/src_components')
local WorldsService = main.Core.Services.WorldsService()
local CollectionService = game:GetService('CollectionService')

local model = components.property.Model()
local fetch = components.action.Fetch()

local private = {};
local interface = {};

type System = typeof(interface.Service)

interface.Service = main.Core.Classes.SadSystemService().new({
	Name = script.Name;
	TargetWorld = WorldsService.Service:GetWorld('game.world');
});

function private.Action (World)
	local Service = interface.Service
	local PhaseLog = Service:DoPhaseLog()
	
	fetch:DoCatchFromWorld(World, function(Component1: { FetchTag: string }) 
		local IsModel = model:DoCatchFromWorld(World, function(Component2: { Path: string, Source: string }) 
			if Component1.FetchTag == '' then
				PhaseLog.Insert(2, true)
				if Component2.Path ~= '' then
					PhaseLog.Insert(3, true)
					local this = main.Libs.RbxUtility.FromPath(Component2.Path) :: PVInstance?
					if this then
						Component1.FetchTag = main.Libs.CodeUtility.RandomStr()
						if main.Libs.CodeUtility.IsParallelContext() then
							task.synchronize()
							CollectionService:AddTag(this, Component1.FetchTag)
							task.desynchronize()
						end
						PhaseLog.Insert(5, true)
					end
					PhaseLog.Insert(4, this ~= nil)
				end
			else
				local this = CollectionService:GetTagged(Component1.FetchTag)[1]
				if this then
					local name = this:GetFullName()
					if Component2.Path ~= name then
						PhaseLog.Insert(-3, true)
						Component2.Path = name
					end
				end
				PhaseLog.Insert(-2, this ~= nil)
			end
		end)
		
		PhaseLog.Insert(1, IsModel)
	end)
	PhaseLog.EndLog(World.Identity)
end


interface.Service:DoWhileActive():ConnectParallel(function(deltaTime: number, NewCycle: boolean) 
	interface.Service.TargetWorld:DoForWorlds(private.Action)
end)

return interface