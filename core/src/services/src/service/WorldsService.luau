local main = require('../')
local Mapping = main.Mapping
local private = {}
local interface = {}

type GameWorldsService = typeof(interface.Service)
local SharedTableRegistry = game:GetService('SharedTableRegistry')
local SadWorld = main.Core.Classes.SadWorld()
type SadWorld = typeof(SadWorld.new())
type Worlds = keyof<typeof(main.Mapping.Worlds)>

private.shared_worlds = {} :: {[string]: SadWorld}

function private:get_shared_world (Identity: Worlds | string)
	local self = self :: GameWorldsService;
	local world = private.shared_worlds[Identity]
	if world then
		return world
	end
	
	local shared = SharedTableRegistry:GetSharedTable(Identity)
	world = SadWorld.new(Identity)
	
	if not shared.Identity then
		for i,v in world do
			SharedTable.update(shared, i, function(arg) 
				if arg == nil then
					return v
				end
				return arg
			end)
		end
	else
		world.Worlds = shared.Worlds
		world.Components = shared.Components		
	end
	
	private.shared_worlds[Identity]=world
	
	return world
end

function private:remove_shared_world (Identity: Worlds | string)
	local self = self :: GameWorldsService;

	private.shared_worlds[Identity]=nil
	SharedTableRegistry:SetSharedTable(Identity,nil)
end

function private.is_world_exists_in_SharedRegistry (Identity: string)
	return SharedTableRegistry:GetSharedTable(Identity).Identity ~= nil
end

function private:is_world_exist (Identity: Worlds | string)
	local self = self :: GameWorldsService;
	return private.shared_worlds[Identity] ~= nil
end

function private:is_it_world (this: any)
	return SadWorld.class.IsA(this, 'SadWorld')
end

interface.Service = main.Core.Classes.SadCoreService().new({
	
	GetWorld = private.get_shared_world;
	IsExistsWorld = private.is_world_exist;
	DoRemoveWorld = private.remove_shared_world;
	IsItWorld = private.is_it_world;
	
	Name = script.Name;
})

return interface