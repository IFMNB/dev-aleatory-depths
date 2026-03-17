local main = require('../../../');
local components = require('../../../interface/src_components')
local WorldsService = main.Core.Services.WorldsService()
local CodeUtility = main.Libs.CodeUtility
local Mapping = main.Mapping


local model = components.property.Model()
local rotation = components.parameter.Rotation()

local private = {};
local interface = {};

type System = typeof(interface.Service)

function private.main (World)
	local Service = interface.Service

	
	model:DoCatchFromWorld(World, function(Component1) 
		rotation:DoCatchFromWorld(World, function(Component2: { Look: Vector3, Right: Vector3, Up: Vector3 }) 
			local this = CodeUtility.GetInstanceFrom(Component1.Path) :: PVInstance?
			if this then
				if this.GetPivot then
					local cframe = this:GetPivot()
					
					
					
					if typeof(Component2) == 'SharedTable' then
						local Component2 = Component2 :: SharedTable
						local up = Component2.Up
						local right = Component2.Right
						local look = Component2.Look
						
						SharedTable.update(Component2, 'Up', function (arg)
							if arg == up then
								return cframe.Rotation.UpVector
							end
							return arg
						end)
						
						SharedTable.update(Component2, 'Right', function (arg)
							if arg == right then
								return cframe.Rotation.RightVector
							end
							return arg
						end)
						
						SharedTable.update(Component2, 'Look', function (arg)
							if arg == look then
								return cframe.Rotation.LookVector
							end
							return arg
						end)
						
					else
						local Component2 = Component2 :: any
						Component2.Up = cframe.Rotation.UpVector
						Component2.Right = cframe.Rotation.RightVector
						Component2.Look = cframe.Rotation.LookVector
					end
				end
			end
		end)
	end)
	
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