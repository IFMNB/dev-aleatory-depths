local main = require('../../../');
local components = require('../../../interface/src_components')
local CodeUtility = main.Libs.CodeUtility
local Mapping = main.Mapping
local WorldsService = main.Core.Services.WorldsService()


local position = components.parameter.Position()
local rotation = components.parameter.Rotation()
local height = components.parameter.Height()
local model = components.property.Model()
local roof = components.sensoric.Roof()
local scale = components.parameter.Scale()

local private = {};
local interface = {};

type System = typeof(interface.Service)
type World = typeof(interface.Service.TargetWorld)
type SharedWorld = typeof(interface.Service.TargetWorld)

interface.Service = main.Core.Classes.SadSystemService().new({
	Name = script.Name;
	TargetWorld = WorldsService.Service:GetWorld('game.world');
});

private.ignore_list = {}
private.params = RaycastParams.new();
private.params.FilterType = Enum.RaycastFilterType.Exclude;
private.params.RespectCanCollide = true;
private.params.IgnoreWater = true;
private.params.FilterDescendantsInstances = private.ignore_list;

function private.main (World)
	local Service = interface.Service
	
	roof:DoCatchFromWorld(World, function(Component1)
		local PhaseLog = Service:DoPhaseLog()
		PhaseLog.Insert(1,true)
		
		local IsPositionCatched = position:DoCatchFromWorld(World, function(Component2)
			local Rotation = Vector3.yAxis
			local Position = Component2.Value
			local Size = 1
			
			if Component1.IsLocalCoordinate then
				local IsRotationCatched = rotation:DoCatchFromWorld(World, function(Component3)
					Rotation = Component3.Value.UpVector
				end)
				PhaseLog.Insert(3, IsRotationCatched)
			end
			
			height:DoCatchFromWorld(World, function(Component4) 
				Rotation *= Component4.Value
				PhaseLog.Insert(4, true)
			end)
			
			model:DoCatchFromWorld(World, function(Component6) 
				local value = CodeUtility.GetInstanceFrom(Component6.Path) :: Model?
				if value then
					table.insert(private.ignore_list,value)
				end
				PhaseLog.Insert(5, value ~= nil)
			end)
			
			scale:DoCatchFromWorld(World, function(Component7: { Value: number }) 
				Size = Component7.Value
				PhaseLog.Insert(6, true)
			end)
			
			local Direction = Rotation * 10
			local RaycastResultRaw = workspace:Spherecast(Position, Size, Direction, private.params)
			local RaycastResult
			if RaycastResultRaw then
				RaycastResult = {
					Instance = RaycastResultRaw.Instance:GetFullName(),
					Position = RaycastResultRaw.Position,
					Distance = RaycastResultRaw.Distance,
					Material = RaycastResultRaw.Material,
					Normal = RaycastResultRaw.Normal
				}
			end
			
			Service.TargetWorld.DoUpdateComponent(World, roof.Name, 'Value', function(old, current) 
				if current == old then
					return RaycastResult
				end
				return current
			end)
			
			table.clear(private.ignore_list)
			if Service:IsDevActive() then
				if main.Libs.CodeUtility.IsParallelContext() then
					task.synchronize()
				end
				
				local Debris = game.Debris
				local Attachment1 = Instance.new('Attachment')
				local Attachment2 = Instance.new('Attachment')
				local Beam = Instance.new('Beam')
				
				Beam.FaceCamera = true
				Attachment1.Parent = Beam
				Attachment2.Parent = Beam
				Beam.Attachment0 = Attachment1
				Beam.Attachment1 = Attachment2
				Attachment1.Position = Position
				Attachment2.Position = Position + Direction
				Beam.Color = ColorSequence.new(Color3.fromRGB(125,200,200))
				Beam.Name = Service.Name
				Beam.Parent = workspace:FindFirstChild('temp') or workspace 
				
				Debris:AddItem(Beam, Service.UpdateRate)
				Debris:AddItem(Attachment1, Service.UpdateRate)
				Debris:AddItem(Attachment2, Service.UpdateRate)
			end
		end)
		
		PhaseLog.Insert(2, IsPositionCatched)
	end)
end

interface.Service:DoWhileActive():ConnectParallel(function(deltaTime: number, NewCycle: boolean)
	local TargetWorld = interface.Service.TargetWorld
	if WorldsService.Service:IsItWorld(TargetWorld) then
		TargetWorld:DoForWorlds(private.main)
	end
end)

return interface