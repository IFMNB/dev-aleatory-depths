local main = require('./');

local HxNode = main.Libs.Hexagon.Classes.HxNode()

local private = {};
local class = {}; setmetatable(class,class);
local interface = {};

type HxNode = typeof(HxNode.new(private.new()))
type SadWorld = typeof(private.new())
type Identity = string

--[[
	Создает простой EC объект.
	
	Может содержать в себе как другие такие же объекты,
	так и ничего не содержать кроме компонентов.
	
	@class SadWorld
	@side all
	@return Instance (@P SadWorld)
]]
function private.new (Identity: string?)
	local this = main.new({
		Elements = {} :: typeof(class.Elements);	
		Identity = Identity or tostring(os.clock());
		Components = {} :: typeof(class.Components);
	}, class)
	
	return this
end

type CallbackFunction = (Entity: SadWorld)->()

--[[
	Выполняет CallbackFunction для всех объектов в цепи.
	
	@class SadWorld
	@side all
	@return ()
]]
function private:iter_head (Callback: CallbackFunction)
	local self = self :: SadWorld
	local node = self.Head :: HxNode?
	while node do
		Callback(node.Value)
		node = node.NextNode
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
	local head = self.Head
	local new_node = HxNode.new(private.new(Identity),nil,head)
	if head then
		head.BackNode = new_node
	end
	
	self.Elements[new_node.Value.Identity] = new_node
	self.Head = new_node
	
	return new_node.Value.Identity
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
	local node = self.Elements[Identity] :: HxNode?
	if node then
		local backnode = node.BackNode :: HxNode?
		local nextnode = node.NextNode :: HxNode?
		
		if backnode then
			backnode.NextNode = nextnode
		end
		if nextnode then
			nextnode.BackNode = backnode
		end
		
		if node == self.Head then
			(self::SadWorld).Head = nextnode
		end
		
		self.Elements[Identity] = nil
		
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
function private:add_com <N,T> (Component)
	local self = self :: SadWorld
	local name = Component.Name
	self.Components[name]=Component
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
	if self.Components[Name] then
		self.Components[Name]=nil
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