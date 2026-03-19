local main = require('../../../');
local components = require('../../../interface/src_components')
local WorldsService = main.Core.Services.WorldsService()
local CodeUtility = main.Libs.CodeUtility
local Mapping = main.Mapping


local model = components.property.Model()
local rotation = components.parameter.Rotation()
local rotate = components.action.Rotate()

local private = {};
local interface = {};

type System = typeof(interface.Service)

function private.main (World)
	local Service = interface.Service

	rotation:DoCatchFromWorld(World, function(ComRot) 
		model:DoCatchFromWorld(World, function(ComMod) 
			private.fetch_rotation(World,ComMod, ComRot)
			private.apply_action_rotate(World, ComMod, ComRot)
		end)
	end)
end

function private.apply_action_rotate (World, ComMod: typeof(model.Value), ComRot: typeof(rotation.Value))
	rotate:DoCatchFromWorld(World, function(Component: { ToOrientation: CFrame })
		rotate:DoDestroyFromWorld(World)
		
		local this = CodeUtility.GetInstanceFrom(ComMod.Path) :: PVInstance?
		
		if this then
			if this.PivotTo then
				local CurrentPivot = this:GetPivot()
				local TargetFrame = CurrentPivot * Component.ToOrientation
				
				CodeUtility.DoCallContextSync(function(...) 
					return this:PivotTo(TargetFrame)
				end)
			end
		end
	end)
end

function private.fetch_rotation (World, ComMod: typeof(model.Value), ComRot: typeof(rotation.Value))
	local this = CodeUtility.GetInstanceFrom(ComMod.Path) :: PVInstance?
	if this then
		if this.GetPivot then
			local Pivot = this:GetPivot()
			
			ComRot.Previous = ComRot.Value
			ComRot.Value = Pivot.Rotation
		end
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