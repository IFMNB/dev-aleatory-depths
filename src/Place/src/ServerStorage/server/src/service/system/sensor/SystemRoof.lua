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
local service = main.Core.Classes.SadSystemService().new({
	Name = script.Name;
	TargetWorld = WorldsService.Service:GetWorld('game.world');
});
local interface = {};

type System = typeof(service)
type World = typeof(service.TargetWorld)
type SharedWorld = typeof(service.TargetWorld)

interface.Service = service

private.ignore_list = {} :: {Instance}
private.params = RaycastParams.new();
private.params.FilterType = Enum.RaycastFilterType.Exclude;
private.params.IgnoreWater = true;
private.params.CollisionGroup = 'Default'
private.params.FilterDescendantsInstances = private.ignore_list;

function private.main (World)
	roof:DoCatchFromWorld(World, function(ComRoof)
		private.fetch_roof(World, ComRoof)
		private.visualize_dev(ComRoof.Value and ComRoof.Value.Origin or Vector3.zero,
			ComRoof.Value and ComRoof.Value.Position or Vector3.zero)
	end)
end

function private.fetch_roof (World, ComRoof: typeof(roof.Value))
	position:DoCatchFromWorld(World, function(ComPos)
		local PhaseLog = service:DoPhaseLog()
		local Rotation = Vector3.yAxis
		local Position = ComPos.Value
		local Size = 1
		
		if ComRoof.IsLocalCoordinate then
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
			local value = CodeUtility.GetInstanceFrom(Component6.Path)
			if value then
				table.insert(private.ignore_list, value)
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
				--Instance = CodeUtility.GetInstanceIdentity(RaycastResultRaw.Instance),
				Position = RaycastResultRaw.Position,
				Distance = RaycastResultRaw.Distance,
				Material = RaycastResultRaw.Material,
				Normal = RaycastResultRaw.Normal,
				Origin = Position
			}
		end
		
		ComRoof.Value = RaycastResult
		table.clear(private.ignore_list)
	
		PhaseLog.EndLog('Fetch roof')
	end)
end

function private.visualize_dev (Origin, Hit)
	if service:IsDevActive() then
		CodeUtility.DoCallContextSync(function(...) 
			local Debris = game.Debris
			local Attachment1 = Instance.new('Attachment')
			local Attachment2 = Instance.new('Attachment')
			local Beam = Instance.new('Beam')
			
			Beam.FaceCamera = true
			Attachment1.Parent = Beam
			Attachment2.Parent = Beam
			Beam.Attachment0 = Attachment1
			Beam.Attachment1 = Attachment2
			Attachment1.Position = Origin
			Attachment2.Position = Hit
			Beam.Color = ColorSequence.new(Color3.fromRGB(125,200,200))
			Beam.Name = service.Name
			Beam.Parent = workspace:FindFirstChild('temp') or workspace 
			
			Debris:AddItem(Beam, service.UpdateRate)
			Debris:AddItem(Attachment1, service.UpdateRate)
			Debris:AddItem(Attachment2, service.UpdateRate)
			return
		end)
	end
end

service:DoWhileActive():ConnectParallel(function(deltaTime: number, NewCycle: boolean)
	local TargetWorld = service.TargetWorld
	if WorldsService.Service:IsItWorld(TargetWorld) then
		TargetWorld:DoForWorlds(private.main)
	end
end)

return interface