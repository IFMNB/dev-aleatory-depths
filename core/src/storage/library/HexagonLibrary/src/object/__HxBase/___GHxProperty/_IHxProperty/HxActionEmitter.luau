local main = require('./HxObjectManager')

local private = {};
local class = {}; setmetatable(class,class);
local interface = {};

type F = (...any)->()|any
type HxActionEmitter = typeof(interface.new())
--[[
	Create new HxActionEmitter object.
	
	@class HxActionEmitter
	@return Instance (@P HxActionEmitter)
]]
function private.new ()
	return main.new({
		Listeners = {} :: typeof(class.Listeners);
		OnceAction = false;
	},class)
end
--[[
	Add listener to HxActionEmitter object.

	@class HxActionEmitter
	@return ()
]]
function private:add_listener (Listener: F)
	local self = self :: HxActionEmitter
	table.insert(self.Listeners,Listener)
end
--[[
	Remove listener from HxActionEmitter object.

	@class HxActionEmitter
	@return ()
]]
function private:rem_listener (Listener: F)
	local self = self :: HxActionEmitter
	local index = table.find(self.Listeners,Listener)
	if index then table.remove(self.Listeners,index) end
end
--[[
	Clear all listeners from HxActionEmitter object.

	@class HxActionEmitter
	@return ()
]]
function private:clear_listeners ()
	local self = self :: HxActionEmitter;
	table.clear(self.Listeners)
end

--[[
	Process HxActionEmitter object and call all listeners. 

	@class HxActionEmitter
	@return ()
]]
function private:process (...: any)
	local self = self :: HxActionEmitter
	for i,v in self.Listeners do
		task.spawn(v, ...)
	end
	if self.OnceAction then
		table.clear(self.Listeners)
	end
	return
end

class.__index = main._IHxProperty.class;
class.ClassName = main.ClassNames.HxActionEmmiter;
class.Source=script;
class.Listeners = {} :: {F};

class.AddListener = private.add_listener;
class.RemListener = private.rem_listener;
class.ClearListeners = private.clear_listeners;

class.Process = private.process;
class.OnceAction = false;

interface.class = class;
interface.new = private.new;

return main:expand({HxActionEmitter=interface})