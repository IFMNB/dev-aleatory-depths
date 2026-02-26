local main = require('./__EcsBaseSystem')

local private = {};
local class = {};
class.__index=main.__EcsBase.class;
setmetatable(class,class);
local interface = {};

type EcsWorld = typeof(private.new())
type EcsEntity = typeof(main.EcsEntity.new())


type EcsComponent = typeof(main.EcsComponent.new())
type EcsBaseSystem = typeof(main.__EcsBaseSystem.class)
type EcsAnySystem = EcsBaseSystem | any

function private.new ()
	return main.new({
		Entitys = {} :: typeof(class.Entitys),
		Systems = {} :: typeof(class.Systems),
		Head = class.Head
	},class)
end

function private.head_repair (EcsWorld: EcsWorld, ent_previus_head: EcsEntity, ent_new_head: EcsEntity)
	return ent_previus_head.OnDestroyEvent:Once(function(...)
		ent_new_head.NextEntity = ent_previus_head.NextEntity
		if ent_new_head.NextEntity then
			private.head_repair(EcsWorld, ent_new_head.NextEntity, ent_new_head)
		end
	end)
end

function private.rem_dead (EcsWorld: EcsWorld, ent: EcsEntity)
	local previous_head = EcsWorld.Head
	return ent.OnDestroyEvent:Once(function(...)
		if EcsWorld.Head == ent then EcsWorld.Head = previous_head end
		EcsWorld:RemEntity(ent.EntityId)
	end)
end

function private:add_ent ()
	local self = self :: EcsWorld
	local EcsEntity = main.EcsEntity.new()
	
	if self.Head then
		private.head_repair(self, self.Head, EcsEntity)
		EcsEntity.NextEntity = self.Head
	end
	
	private.rem_dead(self, EcsEntity)
	self.Entitys[EcsEntity.EntityId] = EcsEntity
	self.Head = EcsEntity


	return EcsEntity.EntityId
end

function private:remove_ent (EntityId: string)
	local self = self :: EcsWorld
	local EcsEntity = self:GetEntity(EntityId)
	if EcsEntity then
		EcsEntity.Destroy()
		self.Entitys[EntityId] = nil
	end
	
	return self
end

function private:get_ent (EntityId: string) : EcsEntity
	local self = self :: EcsWorld
	return assert(self.Entitys[EntityId], 'Entity not found')
end

function private:add_sys (System: EcsAnySystem)
	local self = self :: EcsWorld
	local EcsSystem = System :: EcsAnySystem
	local Id = EcsSystem.SystemId
	
	
	assert(not self.Systems[Id], 'System already exists')
	self.Systems[Id] = EcsSystem :: any
	return self
end

function private:remove_sys (SystemId: string)
	local self = self :: EcsWorld
	local EcsSystem = self:GetSystem(SystemId)
	if EcsSystem then
		self.Systems[SystemId] = nil
	end
	
	return self
end

function private:get_sys (SystemId: string)
	local self = self :: EcsWorld
	return assert(self.Systems[SystemId] :: any, 'System not found') :: EcsBaseSystem
end

-- Calls one system for all entities
@native
function private:do_sys (SystemId: string)
	local self = self :: EcsWorld
	local EcsSystem = self:GetSystem(SystemId)
	local Head = self.Head

	while Head do
		EcsSystem:SystemCall(Head)
		Head = Head.NextEntity
	end
	
	return self
end
-- Calls all systems for all entities
@native
function private:do_all ()
	local self = self :: EcsWorld
	local head = self.Head
	
	local t = os.clock()
	while head do
		self:CallEntity(head.EntityId)
		head = head.NextEntity
		
	end
	warn(os.clock()-t)
	
	return self
end

-- Calls all systems for one entity
@native
function private:do_ent (EntityId: string)
	local self = self :: EcsWorld
	local EcsEntity = self:GetEntity(EntityId)
	
	for i,EcsSystem  in self.Systems do
		(EcsSystem::EcsBaseSystem):SystemCall(EcsEntity)
	end
	
	return self
end




class.Head = nil :: EcsEntity?;
class.Entitys = {} :: {[string]: EcsEntity};
class.Systems = {} :: {[string]: EcsBaseSystem};

class.AddSystem = private.add_sys;
class.RemSystem = private.remove_sys;
class.CallSystem = private.do_sys;
class.GetSystem = private.get_sys;

class.AddEntity = private.add_ent;
class.RemEntity = private.remove_ent;
class.GetEntity = private.get_ent;
class.CallEntity = private.do_ent;

class.Call = private.do_all;

class.ClassName = main.ClassNames.EcsWorld;
class.Source = script;

interface.class = class;
interface.new = private.new;

return main:expand({EcsWorld = interface})