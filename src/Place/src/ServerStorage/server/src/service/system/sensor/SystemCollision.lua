local main = require('../../../')
local components = require('../../../interface/src_components')

local CodeUtility = main.Libs.CodeUtility
local Mapping = main.Mapping

local WorldsService = main.Core.Services.WorldsService()
local collision = components.property.Collision()
local collide = components.action.Collide()
local model = components.property.Model()

local private = {};
local service = main.Core.Classes.SadSystemService().new({
	Name = script.Name;
	TargetWorld = WorldsService.Service:GetWorld('game.world')
})
local interface = {}


function private.main (World)
	collision:DoCatchFromWorld(World, function(ComCollision) 
		model:DoCatchFromWorld(World, function(ComMod)
			local this = CodeUtility.GetInstanceFrom(ComMod.Path)
			if this then
				private.action_collide(World, this :: any)
				private.fetch_collision(World, this :: any, ComCollision)
			end
		end)
	end)
end

function private.action_collide (World, Instance: Instance)
	collide:DoCatchFromWorld(World, function(ComCollider) 
		collide:DoDestroyFromWorld(World)
		
		if Instance:IsA('Model') then
			local list = Instance:GetChildren()
			local apply = {} :: {BasePart}
			table.insert(list, Instance)
			
			for i,v in list do
				if v:IsA('BasePart') then
					table.insert(apply, v)
				end
			end
			
			CodeUtility.DoCallContextSync(function(...) 
				for i,v in apply do
					(v::BasePart).CollisionGroup = ComCollider.ColliderGroup
				end
				
				return
			end)
		elseif Instance:IsA('BasePart') then
			CodeUtility.DoCallContextSync(function(...) 
				(Instance::BasePart).CollisionGroup = ComCollider.ColliderGroup
				return
			end)
		end
	end)
end

function private.fetch_collision (World, Instance: Instance, ComCollision: typeof(collision.Value))
	if Instance:IsA('BasePart') then
		ComCollision.CollisionGroup = Instance.CollisionGroup
	elseif Instance:IsA('Model') then
		if Instance.PrimaryPart then
			ComCollision.CollisionGroup = Instance.PrimaryPart.CollisionGroup
		end
	end
end

interface.Service = service
service:DoWhileActive():ConnectParallel(function(deltaTime: number, NewCycle: boolean) 
	if WorldsService.Service:IsItWorld(service.TargetWorld) then
		service.TargetWorld:DoForWorlds(private.main)
	end
end)

return interface