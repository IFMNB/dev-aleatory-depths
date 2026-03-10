local main = require('../../');

local WorldsService = main.Core.Services.WorldsService()
local components = require('../../interface/src_components')

local form = components.Form()
local position = components.Position()

local private = {};
local interface = {};

type System = typeof(interface.Service)

function private.ForWorld (World)
	local Service = interface.Service
	local Phase1 = false
	local Phase2 = false
	
	Phase1 = form:DoCatchFrom(World, function(Component1) 
		Phase2 = position:DoCatchFrom(World, function(Component2) 
			local form = main.Libs.RbxUtility.FromPath(Component1.Path) :: Instance?
			if form and form:IsA('PVInstance') then
				local CurrentPosition = Component2.Value
				local RealPosition = form:GetPivot().Position
				if CurrentPosition == RealPosition then
					return
				else
					local Shared = typeof(Component2) == 'SharedTable' and Component2 
					if Shared then
						SharedTable.update(Shared, 'Value', function(arg) 
							if arg == CurrentPosition then
								return RealPosition
							end
							return arg
						end)
					else
						Component2.Value = RealPosition
					end
				end
			end
		end)
	end)
	
	if not Phase1 then
		if Service:IsLogActive() then
			Service:PrintLog('Unable to find the form component')
		end
		return
	end
	
	if not Phase2 then
		if Service:IsLogActive() then
			Service:PrintLog('Unable to find the position component')
		end
		return
	end
	
	
	if Phase1 and Phase2 then
		if Service:IsLogActive() then
			Service:PrintLog('Positions have been synchronized')
		end
	end		
end

interface.Service = main.Core.Classes.SadSystemService().new({
	Name = script.Name;
	TargetWorld = WorldsService.Service:GetWorld('game.world');
});

interface.Service:DoWhileActive():Connect(function(deltaTime: boolean, NewCycle: boolean)
	if not interface.Service.TargetWorld then return end
	
	interface.Service.TargetWorld:DoFor(private.ForWorld);
	interface.Service.TargetWorld:DoForShared(private.ForWorld);
end)

return interface