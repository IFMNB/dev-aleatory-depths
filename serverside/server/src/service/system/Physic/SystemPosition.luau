local main = require('../../../');
local components = require('../../../interface/src_components')

local WorldsService = main.Core.Services.WorldsService()
local CodeUtility = main.Libs.CodeUtility
local Mapping = main.Mapping


local model = components.property.Model()
local position = components.parameter.Position()
local teleport = components.action.Teleport()
local rotation = components.parameter.Rotation()

local private = {};
local interface = {};

type System = typeof(interface.Service)


function private.main (World)
	local Service = interface.Service
	
	position:DoCatchFromWorld(World, function(ComPos) 
		
		model:DoCatchFromWorld(World, function(Component: { Path: string, Source: string }) 
			local this = CodeUtility.GetInstanceFrom(Component.Path) :: PVInstance?
			
			if this then
				if this.GetPivot or this.PivotTo then
					private.action_teleport(World, this)
					private.fetch_position(World, this, ComPos)
				end
			end
		end)
		
		private.visible_dev(ComPos)
	end)
end

function private.action_teleport (World, This: PVInstance)
	teleport:DoCatchFromWorld(World, function(Component)
		teleport:DoDestroyFromWorld(World)
		local rot = CFrame.new()
		
		rotation:DoCatchFromWorld(World, function(Component: { Previous: CFrame, Value: CFrame }) 
			rot = Component.Value
		end)
		
		CodeUtility.DoCallContextSync(function(...) 
			return This:PivotTo(CFrame.new(Component.ToPosition) * rot)
		end)
	end)
end

function private.fetch_position (World, This: PVInstance, ComPos: typeof(position.Value))
	local Pivot = This:GetPivot()
	ComPos.Previous = ComPos.Value
	ComPos.Value = Pivot.Position
end

function private.visible_dev (PosComponent)
	if interface.Service:IsDevActive() then
		CodeUtility.DoCallContextSync(function(...) 
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
			
			return	
		end)
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