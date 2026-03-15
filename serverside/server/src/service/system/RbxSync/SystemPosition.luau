local main = require('../../../');
local components = require('../../../interface/src_components')

local WorldsService = main.Core.Services.WorldsService()

local model = components.property.Model()
local position = components.parameter.Position()
local teleport = components.action.Teleport()

local private = {};
local interface = {};

type System = typeof(interface.Service)

function private.ForWorld (World)
	local Service = interface.Service

	
	position:DoCatchFromWorld(World, function(Component2) 
		local Path = ''
		
		model:DoCatchFromWorld(World, function(Component1) 
			Path = Component1.Path
		end)
		
		local form = main.Libs.RbxUtility.FromPath(Path) :: Instance?
		if form and form:IsA('PVInstance') then
			local CurrentPosition = Component2.Value
			
			teleport:DoCatchFromWorld(World, function(Component: { Value: Vector3 }) 
				form:PivotTo(CFrame.new(Component.Value))
				teleport:DoDestroyFromWorld(World)
			end)
			
			local RealPosition = form:GetPivot().Position
			
			if CurrentPosition ~= RealPosition then
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
		
		if Service:IsDevActive() then
			if main.Libs.CodeUtility.IsParallelContext() then
				task.synchronize()
			end
			
			local attachment = Instance.new('Part')
			attachment.Name = position.Name..'_'..World.Identity::string
			attachment.CFrame = CFrame.new(Component2.Value)
			attachment.Parent = workspace:FindFirstChild('temp') or workspace
			attachment.CanCollide = false
			attachment.CanQuery = false
			attachment.CanTouch = false
			attachment.AudioCanCollide = false
			attachment.Anchored = true
			attachment.Transparency = 0
			attachment.Material = Enum.Material.Neon
			attachment.Color = Color3.fromRGB(200,110,200)
			attachment.Size = Vector3.new(3,3,3)
			attachment.Shape = Enum.PartType.Ball
			
			game.Debris:AddItem(attachment, 1)
		end
	end)
	
end

interface.Service = main.Core.Classes.SadSystemService().new({
	Name = script.Name;
	TargetWorld = WorldsService.Service:GetWorld('game.world');
});

interface.Service:DoWhileActive():ConnectParallel(function(deltaTime: number, NewCycle: boolean)
	if interface.Service.IsA(interface.Service.TargetWorld, 'SadWorld') then
		interface.Service.TargetWorld:DoForWorlds(private.ForWorld);
	end
end)

return interface