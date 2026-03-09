local main = require('./');

local HxNode = main.Libs.Hexagon.Classes.HxNode()
local SharedTableRegistry = game:GetService('SharedTableRegistry')

local private = {};
local class = {}; setmetatable(class,class);
local interface = {};

type HxNode = typeof(HxNode.new(private.new()))
type SadWorld = typeof(private.new())
type Identity = string

--[[
	Экземпляр этого класса взаимозаменяем фактически везде, включая даже в компонентах.
	
	@class SadWorld
	@side all
	@return Instance (@P SadWorld)
]]
function private.new (Identity: string?)
	local this = main.new({
		Elements = {} :: typeof(class.Elements);	
		Identity = Identity or tostring(os.clock()..class.ClassName);
		Components = {} :: {[string]: Component};
		Head = nil :: HxNode?;
	}, class)
	

	local shared = SharedTableRegistry:GetSharedTable(this.Identity)
	if not shared['Elements'] then
		SharedTable.update(shared, 'Elements', function(arg) 
			return {}
		end)
	end
	if not shared['Components'] then
		SharedTable.update(shared, 'Components', function(arg) 
			return {}
		end)
	end
	if not shared['Identity'] then
		SharedTable.update(shared, 'Identity', function(arg) 
			return Identity
		end)
	end
	
	return this
end

type RawHxNode = {
	Value: RawSadWorld?;
	BackNode: RawHxNode?;
	NextNode: RawHxNode?;
}
export type RawSadWorld = {
	Elements: {[string]: RawHxNode?};
	Head: RawHxNode?;
	Identity: string;
	Components: {[string]: Component}
}
type Component = {[any]:unknown}
type SharedSadWorld = SharedTable & RawSadWorld -- багует типы
type CallbackFunction = (World: SadWorld)->()
type CallbackSharedFunction = (RawWorld: SharedSadWorld) -> ()

--[[
	Выполняет CallbackFunction для всех объектов в цепи.
	
	@class SadWorld
	@side all
	@return boolean
]]
function private:iter_head (Callback: CallbackFunction)
	local self = self :: SadWorld
	local node = self.Head :: HxNode?
	local iterated = false
	while node do
		xpcall(Callback,warn,node.Value)
		node = node.NextNode
		iterated = true
	end
	return iterated
end



--[[
	Синхронизирует локальные компоненты мира с их Shared версиями.

	При обычной работе с SadWorld несколько систем могут атомарно или неатомарно работать с
	одним и тем же миром, вставляя и удаляя объекты.
	

	@class SadWorld
	@side all
	@return ()
]]
function private:sync_shared_components ()
	local self = self :: SadWorld
	local this = self:GetShared()
	local Components = SharedTable.cloneAndFreeze(this.Components, true) :: typeof(table.freeze({}::{[string]:Component}))
	for Name, Component in Components do
		for index,value in Component do
			Component[index]=value
		end
	end
end

--[[
	Выполняет CallbackFunction для целевого объекта.
	
	@class SadWorld
	@side all
	@return boolean
]]
function private:iter_target (Callback: CallbackFunction, Identity: Identity)
	local self = self :: SadWorld
	local node = self.Elements[Identity] :: HxNode?
	if node then
		xpcall(Callback,warn,node.Value)
		return true
	end
	
	return false
end

--[[
	Выполняет CallbackFunction для всего дерева этого объекта.
	
	@class SadWorld
	@side all
	@return boolean
]]
function private:iter_recursive (Callback: CallbackFunction)
	local self = self :: SadWorld
	return self:DoIter(function (world)
		xpcall(Callback,warn,world)
		world:DoIterRecursive(Callback)
	end)
end

--[[
	Выполняет CallbackFunction для всех объектов в цепи.
	
	Метод является параллельным, а значит не обеспечивает никакой безопасности работы с объектами.
	Выполняемые операции будут производиться с данными "как есть",
	без какой-либо метатаблицы или других оберток.
	
	@class SadWorld
	@side all
	@return boolean
]]
function private:iter_shared (Callback: CallbackSharedFunction)
	local self = self :: SadWorld
	local this = SharedTableRegistry:GetSharedTable(self.Identity) :: SharedSadWorld
	local node = this.Head :: HxNode?
	local iterated = false
	while node do
		xpcall(Callback,warn,node.Value)
		node = node.NextNode
		iterated = true
	end
	return iterated
end

--[[
	Выполняет CallbackFunction для целевого объекта.
	
	Метод является параллельным, а значит не обеспечивает никакой безопасности работы с объектами.
	Выполняемые операции будут производиться с данными "как есть",
	без какой-либо метатаблицы или других оберток.
	
	@class SadWorld
	@side all
	@return boolean
]]
function private:iter_shared_target (Callback: CallbackSharedFunction, Identity: Identity)
	local self = self :: SadWorld
	local this = SharedTableRegistry:GetSharedTable(self.Identity) :: SharedSadWorld
	local node = this.Elements[Identity] :: HxNode?
	if node then
		xpcall(Callback,warn,node.Value)
		return true
	end
	
	return false
end

--[[
	Выполняет CallbackFunction для всего дерева этого объекта.
	
	Метод является параллельным, а значит не обеспечивает никакой безопасности работы с объектами.
	Выполняемые операции будут производиться с данными "как есть",
	без какой-либо метатаблицы или других оберток.
	
	@class SadWorld
	@side all
	@return boolean
]]
function private:iter_shared_recursive (Callback: CallbackSharedFunction)
	local self = self :: SadWorld
	return class.DoSharedIter(SharedTableRegistry:GetSharedTable(self.Identity), function (world)
		xpcall(Callback,warn,world)
		class.DoSharedIterRecursive(world, Callback)
	end)
end


--[[
	Добавит в объект еще один такой же объект.
	
	@class SadWorld
	@side all
	@return string
	@usage
		local world = SadWorld.new()
		local identity = world:add()
]]
function private:add (Identity: Identity?)
	local self = self :: SadWorld
	local Identity = private.add_world_to_world(self, Identity)
	private.add_shared_world_to_shared_world(self:GetShared(), Identity)
	return Identity
end

function private.add_world_to_world (world: SadWorld, Identity: Identity?)
	local head = world.Head
	local new_world = private.new(Identity)
	local new_node = HxNode.new(new_world,nil,head) :: HxNode
	if head then
		head.BackNode = new_node
	end
	
	world.Elements[new_world.Identity] = new_node
	world.Head = new_node
	
	return new_world.Identity
end

function private.add_shared_world_to_shared_world (shared_world: SharedSadWorld, Identity: Identity?)
	local head = shared_world.Head
	local new_shared_world = private.new(Identity)
	local new_node = HxNode.new(new_shared_world,nil,head) :: HxNode
	if head then
		SharedTable.update(head, 'BackNode', function(arg) 
			return new_node
		end)
	end
	
	SharedTable.update(shared_world.Elements, new_shared_world.Identity, function(arg) 
		return new_shared_world
	end)
	SharedTable.update(shared_world, 'Head', function(arg) 
		return new_node
	end)
	
	return new_shared_world.Identity
end

--[[
	Удалит из этого мира другой мир с заданным идентификатором.
	
	Вернет true если такой объект существовал.
	
	@class SadWorld
	@side all
	@return boolean
]]
function private:rem(Identity: Identity)
	local self = self :: SadWorld
	return
		private.remove_world_from_world(self, Identity) and
		private.remove_shared_world_from_shared_world(self:GetShared(),Identity)
end

function private.remove_world_from_world (world: SadWorld, Identity: Identity)
	local node = world.Elements[Identity] :: HxNode?
	if node then
		local back_node = node.BackNode :: HxNode?
		local next_node = node.NextNode :: HxNode?
		
		if back_node then
			back_node.NextNode = next_node
		end
		if next_node then
			next_node.BackNode = back_node
		end
		if world.Head == node then
			world.Head = next_node
		end
		
		world.Elements[Identity]=nil
		return true
	end
	return false
end

function private.remove_shared_world_from_shared_world (shared_world: SharedTable, Identity: Identity)
	local this = shared_world.Elements[Identity] :: SharedTable?
	if this and this.Identity == Identity then
		local node = this.Elements[Identity] :: SharedTable?
		if node then
			local back_node = node.BackNode :: SharedTable?
			local next_node = node.NextNode :: SharedTable?
			
			if back_node then
				SharedTable.update(back_node, 'NextNode', function(arg) 
					return next_node
				end)
			end
			if next_node then
				SharedTable.update(next_node, 'BackNode', function(arg) 
					return back_node
				end)
			end
			if shared_world.Head == node then
				SharedTable.update(shared_world, 'Head', function(arg) 
					return next_node
				end)
			end
			
			SharedTable.update(shared_world.Elements, Identity, function(arg) 
				return nil
			end)
			return true
		end
	end
	return false
end

--[[
	Добавит в объект компонент с заданным именем, если того не существует.

	@class SadWorld
	@side all
	@return boolean
]]
function private:add_com (Name: string, Component)
	local self = self :: SadWorld
	return
		private.add_component_to_world(self, Name, Component) and
		private.add_component_to_shared_world(self:GetShared(),	Name, Component)
end

function private.add_component_to_world (world: SadWorld, name: string, component)
	local ExistedComponent = world.Components[name] :: unknown
	if ExistedComponent then
		return false
	end
	
	world.Components[name]=component
	return true
end

function private.add_component_to_shared_world (shared_world: SharedSadWorld, name: string, component)
	local ExistedComponent = shared_world.Components[name] :: unknown
	if ExistedComponent then
		return false
	end
	
	SharedTable.update(shared_world.Components, name, function(arg) 
		return component
	end)
	
	return true
end

--[[
	Удалит из объекта компонент по имени.

	Вернет true если компонент существовал.

	@class SadWorld
	@side all
	@return boolean
]]
function private:rem_com (Name)
	local self = self :: SadWorld
	return 
		private.remove_component_from_world(self, Name) and
		private.remove_component_from_shared_world(self:GetShared(), Name)
end

function private.remove_component_from_world (world: SadWorld, name: string)
	local ExistedComponent = world.Components[name] :: unknown
	if ExistedComponent then
		world.Components[name]=nil
		return true
	end
	return false
end

function private.remove_component_from_shared_world (shared_world: SharedSadWorld, name: string)
	local ExistedComponent = shared_world.Components[name] :: unknown
	if ExistedComponent then
		SharedTable.update(shared_world.Components, name, function(arg) 
			return nil
		end)
		return true
	end
	return false
end


--[[
	Возвращает Shared версию мира.

	@class SadWorld
	@side all
	@return Instance (@P SharedTable)
]]
function private:get_Shared ()
	local self = self :: SadWorld
	local this = SharedTableRegistry:GetSharedTable(self.Identity) :: SharedSadWorld
	return this
end


class.__index = main.SadObject.class;
class.Source = script;
class.ClassName = main.Mapping.Class.SadWorld;

class.AddComponent = private.add_com;
class.RemComponent = private.rem_com;
class.AddElement = private.add;
class.RemElement = private.rem;

class.DoIter = private.iter_head;
class.DoTarget = private.iter_target;
class.DoIterRecursive = private.iter_recursive;

class.DoSharedIter = private.iter_shared;
class.DoSharedTarget = private.iter_shared_target;
class.DoSharedIterRecursive = private.iter_shared_recursive;
class.DoSynchronizeComponents = private.sync_shared_components;

class.GetShared = private.get_Shared;

class.Identity = '';
class.Head = nil :: HxNode?;
class.Components = {};
class.Elements = {};

interface.class = class;
interface.new = private.new;

table.freeze(class)
table.freeze(private)
table.freeze(interface)

return main:expand({SadWorld=interface})