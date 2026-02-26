local main = require('./EcsComponent')
local event = main.I_Base.Classes.HxEvent()

local private = {};
local class = {};
class.__index = main.__EcsBase.class;
setmetatable(class,class);
local interface = {};

type EcsEntity = typeof(interface.new());

function private.new (Next: EcsEntity?)
	local OnDestroyEvent, EventProperties = event.new(private.eventname)
	return main.new({
		EntityId = tostring(tick()),
		Components = {} :: typeof(class.Components),
		NextEntity = Next,
		OnDestroyEvent = OnDestroyEvent,
		Destroy = EventProperties.Call
	},class)
end

function private:add <name, component> (Name: name, Component: component)
	local self = self :: EcsEntity;
	
	assert(not self.Components[Name], string.format('Component %q already exists', tostring(Name)))
	self.Components[Name]=Component
	return self
end

function private:rem <name> (Name: name)
	local self = self :: EcsEntity;
	self.Components[Name]=nil
	return self
end

private.eventname = 'EntityEvent'::'EntityEvent'
class.OnDestroyEvent, private.OnDestroy = event.new(private.eventname);
class.Destroy = private.OnDestroy.Call;
class.RemComponent = private.rem;
class.AddComponent = private.add;
class.ClassName = main.ClassNames.EcsEntity;
class.Source = script;
class.EntityId = '';
class.NextEntity = nil :: EcsEntity?;
class.Components = {};

interface.class = class;
interface.new = private.new;

table.freeze(class)
table.freeze(interface)
table.freeze(private)

return main:expand({EcsEntity=interface})