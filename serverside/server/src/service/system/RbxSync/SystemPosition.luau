local main = require('../../../');
local components = require('../../../interface/src_components')

local WorldsService = main.Core.Services.WorldsService()
local CodeUtility = main.Libs.CodeUtility
local Mapping = main.Mapping


local model = components.property.Model()
local position = components.parameter.Position()
local teleport = components.action.Teleport()

local private = {};
local interface = {};

type System = typeof(interface.Service)


function private.main (World)
	local Service = interface.Service

	
	position:DoCatchFromWorld(World, function(Component2)
		local form
		model:DoCatchFromWorld(World, function(Component1) 
			form = CodeUtility.GetInstanceFrom(Component1.Path) :: Instance?
		end)
		

		if form and form:IsA('PVInstance') then
			private.action_teleport(World, form)
			local RealPosition = form:GetPivot().Position
			local CurrentPosition = Component2.Value

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
		
		private.dev(World, Component2)
	end)
end

function private.action_teleport (World, This: PVInstance)
	teleport:DoCatchFromWorld(World, function(Component: { Value: Vector3 })
		teleport:DoDestroyFromWorld(World)
		This:PivotTo(CFrame.new(Component.Value))
	end)
end

function private.dev (World, PosComponent)
	if interface.Service:IsDevActive() then
		if main.Libs.CodeUtility.IsParallelContext() then
			task.synchronize()
		end

		local Part = Instance.new('Part')
		Part.Name = interface.Service.Name
		Part.CFrame = CFrame.new(PosComponent.Value)
		Part.Parent = workspace:FindFirstChild('temp') or workspace
		Part.CanCollide = false
		Part.CanQuery = false
		Part.CanTouch = false
		Part.AudioCanCollide = false
		Part.Anchored = true
		Part.Transparency = 0
		Part.Material = Enum.Material.Neon
		Part.Color = Color3.fromRGB(200,110,200)
		Part.Size = Vector3.new(3,3,3)
		Part.Shape = Enum.PartType.Ball

		game.Debris:AddItem(Part, 1)
	end
end


interface.Service = main.Core.Classes.SadSystemService().new({
	Name = script.Name;
	TargetWorld = WorldsService.Service:GetWorld('game.world');
});

interface.Service:DoWhileActive():ConnectParallel(function(deltaTime: number, NewCycle: boolean)
	local TargetWorld = interface.Service.TargetWorld
	if WorldsService.Service:IsItWorld(TargetWorld) then
		TargetWorld:DoForWorlds(private.main)
	end
end)

return interface