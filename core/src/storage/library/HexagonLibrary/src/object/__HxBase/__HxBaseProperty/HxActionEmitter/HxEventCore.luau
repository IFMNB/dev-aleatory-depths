local main = require('./');

local private = {};
local class = {}; setmetatable(class,class);
local interface = {};

private.mk = {__mode='k'}

local HxConnection = main.HxConnection
local HxEvent = main.HxEvent

type HxEventCore = typeof(class)
type HxEvent <Reactor=any> = typeof(HxEvent.new(nil::Reactor))
type HxEventConnection = typeof(HxConnection.new())
type HxActionEmitter = typeof(main.HxActionEmitter.new())

type Name <T=string> = T
type DefaultFunction = (...any)->()
type F = (...any)->()
type ConType = 'Connection'|'Once'
type RunType = 'Parallel'|'Serial'
type ListenerConnection = {
	Connection: HxEventConnection,
	Type: ConType,
	Run: RunType,
	Func: F
}
type Listener = ()->ListenerConnection
type Connect = (self: HxEvent, Function: F)->HxEventConnection
type SelfDefF <T=()->...any, U=string> = {DefaultFunction: T, Name: U} | any

--[[
	Passes through all connections inside HxEventCore and performs all functions.

	@class HxEventCore
	@return ()
]]
function private:call_properties (...) : ()
	local self = self :: HxEventCore

	
	for i,v in self.Listeners do
		local this = v();
		
		if this.Run == 'Serial' then
			--coroutine.resume(coroutine.create(this.Func),...)
			--task.spawn(function (...) this.Connection.Output = this.Func(...) end, ...)
			this.Connection.Output = this.Func(...)
		elseif this.Run == 'Parallel' then
			task.spawn(function (...) task.desynchronize() this.Connection.Output = this.Func(...) end,...)
		else
			warn('Invalid Connection RunType', this.Run)
			self:RemListener(v)
			continue
		end
		
		if this.Type == 'Once' then
			self:RemListener(v)
		end
	end
	
	return
end

--[[
	Creates a new HxEventCore.
	
	@class HxEventCore
	@return Instance (@P HxEventCore)
]]
function private.new_event_properties <U, T> (DefaultFunction: T|DefaultFunction?, Name: U|Name?)
	local raw = {}
	local lambda : HxEventCore
	
	raw.Listeners = {};
	raw.EventsWatchers = setmetatable({}, private.mk);
	raw.Name = Name :: U;
	raw.Alive = true;
	raw.DefaultFunction = DefaultFunction :: T;
	raw.KillEvent = setmetatable({}, private.mk)
	
	--[[
		Wrapped function for DoCall.
	
		@class HxEventCore
		@return *unknown*
	]]
	function raw.SelfCall (...) : ()
		return lambda:DoCall(...)
	end
	
	local this = main.new(raw, class)
	lambda = this :: any
	return this
end

--[[
	Creates a new HxEvent from the HxEventCore.
	
	@class HxEventCore
	@return Instance (@P HxEvent)
]]
function private.create_event <T,U> (self: SelfDefF<T,U>)
	--local Event = private.new_event(self, self.Name);
	local Event, KillEvent = HxEvent.new(function(DefaultFunction: (...any) -> (), ConnectionType: "Connection" | "Once", RunType: "Parallel" | "Serial") 
		local this : ListenerConnection = {} :: any
		local self = self :: HxEventCore;
		
		local function Listener ()
			return this
		end
		local Connection = HxConnection.new(function(HxConnection) 
			self:RemListener(Listener)
		end);
		
		self:AddListener(Listener)
		
		this.Connection = Connection;
		this.Type = ConnectionType;
		this.Run = RunType;
		this.Func = DefaultFunction;
		
		table.freeze(this)
		
		return Connection;
	end, self.DefaultFunction :: T, self.Name :: U)
	
	local self = self :: HxEventCore;
	
	local HxActionEmitter = main.HxActionEmitter.new();
	HxActionEmitter.OnceAction = true;
	
	self.EventsWatchers[Event] = HxActionEmitter;
	self.KillEvent[Event]=KillEvent;
	return Event
end

--[[
	Destroys the HxEvent from the HxEventCore.
	
	@class HxEventCore
	@return ()
]]
function private:destroy_event (HxEvent)
	local self = self :: HxEventCore;
	local HxEvent = assert(self.IsA(HxEvent, 'HxEvent'), 'Invalid HxEvent') and HxEvent :: HxEvent;
	local Event = self.KillEvent[HxEvent] and self.EventsWatchers[HxEvent];
	if Event then
		self.KillEvent[HxEvent]();
		table.freeze(HxEvent);
		Event:Process(HxEvent);
		self.EventsWatchers[HxEvent] = nil;
	else
		if game["Run Service"]:IsStudio() then
			warn('HxEventCore does not have received HxEvent \n', debug.traceback())
		end
	end
end

--[[
	Clears all HxConnection's of the HxEventCore.

	@override
	@class HxEventCore
	@return ()
]]
function private:clear_listeners ()
	local self = self :: HxEventCore;
	for i,v in self.Listeners do
		local this = v();
		this.Connection:Disconnect()
	end
	class.__index.ClearListeners(self)
end

--[[
	Destroys the HxEventCore.
	
	Upon destruction, all connections and events of this core are disabled.

	@class HxEventCore
	@return ()
]]
function private:destroy_properties ()
	local self = self :: HxEventCore;
	for i,v in self.EventsWatchers do
		self:RemEvent(i);
	end
	
	print(self.EventsWatchers)
	table.clear(self.EventsWatchers)
	
	self.Alive = false
	self:ClearListeners()
	
	table.freeze(self)
	table.freeze(self.Listeners)
	table.freeze(self.EventsWatchers)
end


class.__index = main.HxActionEmitter.class;
class.ClassName = main.ClassNames.HxEventCore;
class.Source = script;
class.Listeners = table.freeze({}:: {Listener});
class.EventsWatchers = table.freeze(setmetatable({} :: {[HxEvent]: HxActionEmitter}, private.mk));
class.KillEvent = table.freeze(setmetatable({} :: {[HxEvent]: ()->()}, private.mk));
class.DefaultFunction = warn :: DefaultFunction;
class.Name = '' :: Name;
class.Alive = false;
class.AddEvent = private.create_event;
class.RemEvent = private.destroy_event;

class.DoCall = private.call_properties;
class.DoCallSelf = main.Abstract.ShouldOverrided;

class.Destroy = private.destroy_properties; 
class.ClearListeners = private.clear_listeners;

interface.class = class;
interface.new = private.new_event_properties;


table.freeze(class)
table.freeze(interface)
table.freeze(private)

return main:expand({HxEventCore = interface})