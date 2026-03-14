local main = require('../../../');
local components = require('../../../interface/src_components')

local WorldsService = main.Core.Services.WorldsService()

local model = components.property.Model()
local position = components.parameter.Position()

local private = {};
local interface = {};

type System = typeof(interface.Service)

function private.ForWorld (World)
	local Service = interface.Service
	local Phase = {}
	
	Phase[1] = model:DoCatchFromWorld(World, function(Component1) 
		Phase[2] = position:DoCatchFromWorld(World, function(Component2) 
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
	
	if Service:IsLogActive() then
		local fails = false
		for i,v in Phase do
			if not v then
				fails = true
				Service:PrintLog(string.format('Failed Phase%s, %s', tostring(i), World.Identity))
			end
		end
		if not fails then
			Service:PrintLog(string.format('Success, %s', World.Identity))
		end
	end
end

interface.Service = main.Core.Classes.SadSystemService().new({
	Name = script.Name;
	TargetWorld = WorldsService.Service:GetWorld('game.world');
});

interface.Service:DoWhileActive():ConnectParallel(function(deltaTime: number, NewCycle: boolean)
	if not interface.Service.TargetWorld then return end
	
--	interface.Service.TargetWorld:DoFor(private.ForWorld);
	interface.Service.TargetWorld:DoForWorlds(private.ForWorld);
end)

return interface