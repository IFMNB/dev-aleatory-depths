local main = require('../../');

local WorldsService = main.Core.Services.WorldsService()
local components = require('../../interface/src_components')

local position = components.Position()
local rotation = components.Rotation()
local height = components.Height()
local model = components.Model()
local form = components.Form()
local surface = components.Surface()

local private = {};
local interface = {};

type System = typeof(interface.Service)
type World = typeof(interface.Service.TargetWorld)
type SharedWorld = typeof(interface.Service.TargetWorld:GetShared())

interface.Service = main.Core.Classes.SadSystemService().new({
	Name = script.Name;
	TargetWorld = WorldsService.Service:GetSharedWorld('game.world');
});

function private.Action (World)
	local Service = interface.Service
	local Phase = {}
	
	Phase[1] = surface:DoCatchFrom(World, function(Component1: { Value: RaycastResult? }) 
		Phase[2] = position:DoCatchFrom(World, function(Component2: { Value: Vector3 }) 
			local RotationVectorDown = Vector3.new(0,-1,0)
			local Position = Component2.Value
			local Height = 1
			
			Phase[3] = rotation:DoCatchFrom(World, function(Component3: { Look: Vector3, Right: Vector3, Up: Vector3 }) 
				RotationVectorDown = -Component3.Up
			end)
			
			Phase[4] = height:DoCatchFrom(World, function(Component4: { Value: number }) 
				Height = Component4.Value
			end)
			
			local IgnoreList = {}
			
			Phase[5] = form:DoCatchFrom(World, function(Component5: { IsTemporal: boolean, Path: string }) 
				local value = main.Libs.RbxUtility.FromPath(Component5.Path)
				if value then
					table.insert(IgnoreList,value)
				end
			end)
			
			Phase[6] = model:DoCatchFrom(World, function(Component6: { IsTemporal: boolean, Path: string }) 
				local value = main.Libs.RbxUtility.FromPath(Component6.Path)
				if value then
					table.insert(IgnoreList,value)
				end
			end)
			
			local RaycastParams = RaycastParams.new()
			RaycastParams.FilterDescendantsInstances = IgnoreList
			RaycastParams.FilterType = Enum.RaycastFilterType.Exclude
			RaycastParams.RespectCanCollide = true
			RaycastParams.IgnoreWater = true
			
			local RaycastResult = workspace:Raycast(Position,RotationVectorDown * Height, RaycastParams)
			Component1.Value = RaycastResult
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

interface.Service:DoWhileActive():Connect(function(deltaTime: number, NewCycle: boolean)
	local TargetWorld = interface.Service.TargetWorld;
	TargetWorld:DoForShared(private.Action)
end)

return interface