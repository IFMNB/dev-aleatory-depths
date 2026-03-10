local main = require('../')
local Mapping = main.Mapping
local private = {}
local interface = {}

type GameWorldsService = typeof(interface.Service)
local SharedTableRegistry = game:GetService('SharedTableRegistry')
local SadWorld = main.Core.Classes.SadWorld()
type SadWorld = typeof(SadWorld.new())
type Worlds = keyof<typeof(main.Mapping.Worlds)>
private.worlds = setmetatable({} :: {[string]: SadWorld}, {__mode='v'})
private.shared_worlds = {} :: {[string]: SadWorld}


--[[
	Доступ к мирам через этот сервис обеспечивает синхронизацию локальных данных на уровне текущего потока.

	@class GameWorldsService
	@side all
	@return Instance (@P SadWorld)
]]
function private:get_world(Identity: Worlds | string)
	local self = self :: GameWorldsService;
	if not self:IsActive() then
		self.OnActiveChangedEvent:Wait()
	end
	
	local World = private.worlds[Identity] or private.shared_worlds[Identity]
	if not World then
		World = SadWorld.new(Identity)
		private.worlds[World.Identity]=World
		
		if self:IsLogActive() then
			self:PrintLog(`World with identity {World.Identity} was created`)
		end
	end
	
	if self:IsLogActive() then
		self:PrintLog(`World with identity {World.Identity} was found`)
	end
	
	return World
end

function private:get_shared_world (Identity: Worlds | string)
	local self = self :: GameWorldsService;
	local world = self:GetWorld(Identity);
	if not private.shared_worlds[world::any] then
		private.shared_worlds[world::any]=(world::any).Shared
		SharedTableRegistry:SetSharedTable(Identity, world.Shared)
	end

	return world
end

function private:remove_shared_world (Identity: Worlds | string)
	local self = self :: GameWorldsService;

	private.shared_worlds[Identity]=nil
	private.worlds[Identity]=nil	
end

function private:is_world_exist (Identity: Worlds | string)
	local self = self :: GameWorldsService;
	
	local World = private.worlds[Identity]
	if World then
		return true
	end
	
	return false
end

interface.Service = main.Core.Classes.SadCoreService().new({
	GetWorld = private.get_world;
	GetSharedWorld = private.get_shared_world;
	IsWorldExist = private.is_world_exist;
	RemoveSharedWorld = private.remove_shared_world;
	
	Name = 'GameCollisionService'::'GameCollisionService';
})

return interface