local main = require('../../../');
local components = require('../../../interface/src_components')

local WorldsService = main.Core.Services.WorldsService()


local position = components.Position()
local rotation = components.Rotation()
local height = components.Height()
local model = components.Model()
local surface = components.Surface()

local private = {};
local interface = {};

type System = typeof(interface.Service)
type World = typeof(interface.Service.TargetWorld)
type SharedWorld = typeof(interface.Service.TargetWorld)

interface.Service = main.Core.Classes.SadSystemService().new({
	Name = script.Name;
	TargetWorld = WorldsService.Service:GetWorld('game.world');
});

private.params = RaycastParams.new();
private.params.FilterType = Enum.RaycastFilterType.Exclude;
private.params.RespectCanCollide = true;
private.params.IgnoreWater = true;

function private.Action (World)
	local Service = interface.Service
	local Phase = {}
	
	Phase[1] = surface:DoCatchFrom(World, function(Component1) 
		Phase[2] = position:DoCatchFrom(World, function(Component2: { Value: Vector3 }) 
			local RotationVectorDown = Vector3.new(0,-1,0)
			local IgnoreList = {}
			local Position = Component2.Value
			
			Phase[3] = rotation:DoCatchFrom(World, function(Component3: { Look: Vector3, Right: Vector3, Up: Vector3 }) 
				RotationVectorDown = -Component3.Up
			end)
			
			Phase[4] = height:DoCatchFrom(World, function(Component4: { Value: number }) 
				RotationVectorDown *= Component4.Value
			end)
		
			Phase[5] = model:DoCatchFrom(World, function(Component6: { IsTemporal: boolean, Path: string }) 
				local value = main.Libs.RbxUtility.FromPath(Component6.Path)
				if value then
					table.insert(IgnoreList::any,value)
				end
			end)
			
			local Direction = RotationVectorDown * 10
			
			task.synchronize()
			private.params.FilterDescendantsInstances = IgnoreList
			task.desynchronize()
			
			local RaycastResultRaw = workspace:Raycast(Position,Direction, private.params)
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
			
			IgnoreList = nil
			local this = Component1.Value
			
			Service.TargetWorld.DoUpdateComponent(World, surface.Name, 'Value', function(old, current) 
				if current == old then
					return RaycastResult
				end
				return current
			end)
			
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
				
				Beam.Name = Service.Name
				Beam.Parent = workspace:FindFirstChild('temp') or workspace 
				
				Debris:AddItem(Beam, Service.UpdateRate)
				Debris:AddItem(Attachment1, Service.UpdateRate)
				Debris:AddItem(Attachment2, Service.UpdateRate)
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

interface.Service:DoWhileActive():ConnectParallel(function(deltaTime: number, NewCycle: boolean)
	local TargetWorld = interface.Service.TargetWorld;
	--	TargetWorld:DoFor(private.Action)
	TargetWorld:DoForWorlds(private.Action)
end)

return interface