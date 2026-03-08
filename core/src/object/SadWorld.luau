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
	Создает простой EC объект.
	
	Может содержать в себе как другие такие же объекты,  так и ничего не содержать кроме компонентов.
	
	SadWorld лучше всего представлять как дерево с множественными ветками.
	Любой мир может быть как просто сущностью, так и с множеством вложенных миров.
	
	Shared-версия мира может отличаться от обычной, т.к экземпляры
	
	@class SadWorld
	@side all
	@return Instance (@P SadWorld)
]]
function private.new (Identity: string?)
	local this = main.new({
		Elements = {} :: typeof(class.Elements);	
		Identity = Identity or tostring(os.clock()..class.ClassName);
		Components = {} :: typeof(class.Components);
	}, class)
	

	local shared = SharedTableRegistry:GetSharedTable(this.Identity)
	if not shared['Elements'] then
		shared['Elements'] = {}
	end
	if not shared['Components'] then
		shared['Components'] = {}
	end
	if not shared['Identity'] then
		shared['Identity'] = this.Identity
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
type Component = {Name: string, [any]:any}
type SharedSadWorld = RawSadWorld-- & SharedTable -- багует типы
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
		Callback(node.Value)
		node = node.NextNode
		iterated = true
	end
	return iterated
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

--[[
	Синхронизирует эту локальную версию мира с его Shared версией.

	@class SadWorld
	@side all
	@return ()
]]
function private:sync_shared_components ()
	local self = self :: SadWorld
	local this = self:GetShared()
	for i,v in this.Components do
		local component = self.Components[i]
		if component then
			for i,v in v do
				component[i]=v
			end
		end
	end
end

--[[
	Выполняет CallbackFunction для целевого объекта.
	
	Вернет true если объект найден.
	
	@class SadWorld
	@side all
	@return boolean
]]
function private:iter_target (Callback: CallbackFunction, Identity: Identity)
	local self = self :: SadWorld
	local node = self.Elements[Identity] :: HxNode?
	if node then
		Callback(node.Value)
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
		Callback(world)
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
		Callback(node.Value)
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
		Callback(node.Value)
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
		Callback(world)
		class.DoSharedIterRecursive(world, Callback)
	end)
end


function private.addworld (this, Identity: Identity?)
	local head = this.Head
	local new_node : any = HxNode.new(private.new(Identity),nil,head)
	if head then
		head.BackNode = new_node
	end
	
	this.Elements[new_node.Value.Identity] = new_node
	this.Head = new_node
	
	return new_node.Value.Identity
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
	if private.addworld(self,Identity) then
		local this = SharedTableRegistry:GetSharedTable(self.Identity) :: SharedSadWorld
		return private.addworld(this :: any,Identity)
	end
end

function private.clearworld (this, Identity: Identity)
	local node : RawHxNode|HxNode? = this.Elements[Identity]
	
	if node then
		local backnode : RawHxNode|HxNode? = node.BackNode
		local nextnode : RawHxNode|HxNode? = node.NextNode
		
		if backnode then
			backnode.NextNode = nextnode
		end
		if nextnode then
			nextnode.BackNode = backnode
		end
		
		if node == this.Head then
			(this::any).Head = nextnode
		end
		
		this.Elements[Identity]=nil
		return true
	end
	return false
end

--[[
	Удалит из объекта объект с заданным идентификатором.
	
	Вернет true если такой объект существовал.
	
	@class SadWorld
	@side all
	@return boolean
]]
function private:rem(Identity: Identity)
	local self = self :: SadWorld
	if private.clearworld(self, Identity) then
		local this = SharedTableRegistry:GetSharedTable(self.Identity) :: SharedSadWorld
		private.clearworld(this,Identity)
		return true
	end
	return false
end

function private.add_component_global (this, Component: Component)
	local name : string = Component.Name
	this.Components[name] = Component
	return true
end

function private.rem_component_global (this, Name: string)
	if this.Components[Name] then
		this.Components[Name]=nil
		return true
	end
	return false
end

--[[
	Добавит в объект компонент с заданным именем.

	@class SadWorld
	@side all
	@return ()
]]
function private:add_com (Component)
	local self = self :: SadWorld
	if private.add_component_global(self, Component) then
		local this = SharedTableRegistry:GetSharedTable(self.Identity) :: SharedSadWorld
		private.add_component_global(this, Component)
		return true
	end
	return false
end

--[[
	Вернет компонент, если он есть.
	
	@class SadWorld
	@side all
	@return Component?
]]
function private:get_component (Name: string) : Component?
	local self = self :: SadWorld
	return self.Components[Name]
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
	if private.rem_component_global(self, Name) then
		local this = SharedTableRegistry:GetSharedTable(self.Identity) :: SharedSadWorld
		private.rem_component_global(this, Name)
		return true
	end
	return false
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