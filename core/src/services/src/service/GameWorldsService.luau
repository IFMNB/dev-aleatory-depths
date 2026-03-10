local main = require('../')
local Mapping = main.Mapping
local private = {}
local interface = {}

type GameWorldsService = typeof(interface.Service)
local SadWorld = main.Core.Classes.SadWorld()
type SadWorld = typeof(SadWorld.new())
type Worlds = keyof<typeof(main.Mapping.Worlds)>
private.worlds = setmetatable({} :: {[string]: SadWorld}, {__mode='v'})


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
	
	local World = private.worlds[Identity]
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

interface.Service = main.Core.Classes.SadCoreService().new({
	GetWorld = private.get_world;
	
	Name = 'GameCollisionService'::'GameCollisionService';
})

return interface