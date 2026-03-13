local main = require('../../');

local WorldsService = main.Core.Services.WorldsService()
local components = require('../../interface/src_components')

local model = components.Model()
local form = components.Form()

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



interface.Service:DoWhileActive():Connect(function(deltaTime: number, NewCycle: boolean)
	local TargetWorld = interface.Service.TargetWorld;
	TargetWorld:DoForWorlds(function (World)
		local Service = interface.Service
		local Phase = {}
		
		if not main.Libs.CodeUtility.IsParallelContext() then
			
			Phase[1] = model:DoCatchFrom(World, private.Subact)
			Phase[2] = form:DoCatchFrom(World, private.Subact)
			
			if Phase[1] or Phase[2] then
				Phase[3] = model:DoCatchFrom(World, function(Component: { IsTemporal: boolean, Path: string }) 
					if Phase[1] then
						model:DoCatchFrom(World.Components, function(OldComponent: { IsTemporal: boolean, Path: string }) 
							OldComponent.Path = Component.Path
							OldComponent.IsTemporal = Component.IsTemporal
						end)
					end
					
					if Phase[2] then
						form:DoCatchFrom(World.Components, function(OldComponent: { IsTemporal: boolean, Path: string }) 
							OldComponent.Path = Component.Path
							OldComponent.IsTemporal = Component.IsTemporal
						end)
					end
				end)
			end
		end
		
		if Service:IsLogActive() then
			local fails : boolean?
			for i,v in Phase do
				if fails == nil then
					fails = false
				end
				
				if not v then
					fails = true
					Service:PrintLog(string.format('Failed Phase%s, %s', tostring(i), World.Identity))
				end
			end
			
			
			if fails == false then
				Service:PrintLog(string.format('Success, %s', World.Identity))
			elseif fails == nil then
				Service:PrintLog(string.format('No Changes, %s', World.Identity))
			end
		end
	end)
end)

return interface