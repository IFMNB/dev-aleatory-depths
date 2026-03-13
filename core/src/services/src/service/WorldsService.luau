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
	if not world then
		world = SadWorld.new(Identity)
		private.shared_worlds[world.Identity]=world
	end

	return world
end

function private:remove_shared_world (Identity: Worlds | string)
	local self = self :: GameWorldsService;

	private.shared_worlds[Identity]=nil
end

function private:is_world_exist (Identity: Worlds | string)
	local self = self :: GameWorldsService;
	return private.shared_worlds[Identity] ~= nil
end

interface.Service = main.Core.Classes.SadCoreService().new({
	GetWorld = private.get_shared_world;
	IsExistsWorld = private.is_world_exist;
	DoRemoveWorld = private.remove_shared_world;
	
	Name = 'GameCollisionService'::'GameCollisionService';
})

return interface