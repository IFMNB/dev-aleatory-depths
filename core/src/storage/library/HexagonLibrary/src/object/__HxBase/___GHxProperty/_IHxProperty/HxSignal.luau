local main = require('./HxActionEmitter');

local private = {};
local class = {}; setmetatable(class,class);
local interface = {};

private.mk = {__mode='k'}

local HxConnection = main.HxConnection
local HxEvent = main.HxEvent

type HxSignal = typeof(class)
type HxEvent <Reactor=any> = typeof(HxEvent.new(nil::Reactor).Value.Event)
type HxEventConnection = typeof(HxConnection.new())
type HxActionEmitter = typeof(main.HxActionEmitter.new())

type Name <T=string> = T
type DefinedCallOut = (...any)->()
type Reactor = (self: HxSignal, TranslatedFunction: DefinedCallOut|unknown, ConType: ConType|unknown, RunType: RunType|unknown, ActionType: ActionType|unknown) -> HxEventConnection
type F = (...any)->()
type ConType = 'Connection'|'Once'
type RunType = 'Parallel'|'Serial'
type ActionType = 'JustConnection' | 'Wait'
type ListenerConnection = {
	Connection: HxEventConnection,
	Type: ConType,
	Run: RunType,
	Func: F
}
type Listener = ListenerConnection
type Connect = (self: HxEvent, Function: F)->HxEventConnection
type SelfDefF <T=()->...any, U=string> = {DefinedCallOut: T, Name: U} | any

--[[
	Creates a new HxSignal.
	
	@class HxSignal
]]
function private.new_event_properties <T> (DefinedCallOut: T|DefinedCallOut?)
	local raw = {}
	local lambda : HxSignal
	
	raw.Listeners = {}
	raw.OnEventDestroyedWatchers = setmetatable({}, private.mk);
	raw.DefinedCallOut = DefinedCallOut :: T;
	raw.EventDestroyersMap = setmetatable({}, private.mk)

	local is_transfer = false
	local is_alive = true
	local my_reactor = private.default_reactor :: typeof(private.default_operator)
	local my_operator = private.default_operator :: (Signal: HxSignal, ...any)->()|any
	
	function raw:IsTransferConnection ()
		return is_transfer
	end
	
	function raw:SetTransferConnection(State:boolean?)
		is_transfer = State or false
	end
	
	function raw:GetReactor ()
		return my_reactor or private.default_reactor
	end
	
	function raw:SetReactor (Reactor: Reactor?)
		my_reactor = Reactor or private.default_reactor
	end
	
	function raw:IsAlive ()
		return is_alive
	end
	
	function raw:GetOperator ()
		return my_operator or private.default_operator
	end
	
	--[[
		@wrapped 
		@class HxSignal
	]]
	function raw:Destroy ()
		is_alive = false
		return class.Destroy(self)
	end
	
	function raw:SetOperator (Operator: (Signal: HxSignal, ...any)->()|any)
		my_operator = Operator or private.default_operator
	end
	
	--[[
		@wrapped
		@class HxSignal
	]]
	function raw.DoCallSelf (...) : ()
		return lambda:DoCall(...)
	end
	
	local this = main.new(raw, class)
	lambda = this :: any
	return this
end


function private:call_properties (...) : ()
	local self = self :: HxSignal
	assert(self:IsAlive(), 'HxSignal is dead')
	return (self:GetOperator() :: typeof(private.default_operator))(self, ...)
end

--[[
	Passes through all connections inside HxSignal and performs all functions.

	@class HxSignal
]]
function private.default_operator (signal: HxSignal, ...: any)
	for i,v in table.clone(signal.Listeners) do
		local this = v;
		
		if this.Run == 'Serial' then
			task.spawn(function (...)
				if main.Abstract.IsParallel() then
					task.synchronize()
				end
				
				if signal:IsTransferConnection() then
					this.Connection.Output = this.Func(this.Connection, ...)
				else
					this.Connection.Output = this.Func(...);
				end
				
			end,...)
		elseif this.Run == 'Parallel' then
			task.spawn(function (...)
				task.desynchronize()
				
				if not main.Abstract.IsParallel() then
					signal:RemListener(v)
					error('Parallel is not supported in this context')
				end 
				
				if signal:IsTransferConnection() then
					this.Connection.Output = this.Func(this.Connection, ...)
				else
					this.Connection.Output = this.Func(...);
				end
				
			end,...)
		else
			warn('Ignored and removed Invalid Connection RunType', this.Run)
			signal:RemListener(v)
			continue
		end
		
		if this.Type == 'Once' then
			signal:RemListener(v)
		elseif this.Type == 'Connection' then
			
		else
			warn('Removed invalid Connection with Type', this.Type)
			signal:RemListener(v)
		end
	end
end

--[[
	Default reactor-function for the HxSignal.
	
	Used to create HxConnection's. This function linked to HxEvent realization.
	
	@class HxSignal
]]
function private:default_reactor (DefinedCallOut: DefinedCallOut, ConnectionType: ConType, RunType: RunType, _: ActionType)
	local this : ListenerConnection = {} :: any
	local self = self :: HxSignal;
	
	local Connection = HxConnection.new(function(HxConnection) 
		self:RemListener(this)
	end);
	
	this.Connection = Connection;
	this.Type = ConnectionType;
	this.Run = RunType;
	this.Func = DefinedCallOut;
	
	self:AddListener(this)
	
	table.freeze(this)
	
	return Connection;
end

--[[
	Clears all HxConnection's of the HxSignal.

	@override
	@class HxSignal
	@return ()
]]
function private:clear_listeners ()
	local self = self :: HxSignal;
	for i,v in self.Listeners do
		local this = v;
		this.Connection:Disconnect()
	end
	class.__index.ClearListeners(self)
end

--[[
	Destroys the HxSignal.
	
	Upon destruction, all connections and events of this core are disabled.

	@class HxSignal
]]	
function private:destroy_properties ()
	local self = self :: HxSignal;
	for i,v in self.OnEventDestroyedWatchers do
		self:RemEvent(i);
	end
	
	print(self.OnEventDestroyedWatchers)
	table.clear(self.OnEventDestroyedWatchers)
	
	self.Alive = false
	self:ClearListeners()
	
	table.freeze(self)
	table.freeze(self.Listeners)
	table.freeze(self.OnEventDestroyedWatchers)
end

--[[
	Destroys the HxEvent from the HxSignal.
	
	@class HxSignal
	@return ()
]]
function private:destroy_event (HxEvent)
	local self = self :: HxSignal;
	local HxEvent = assert(self.IsA(HxEvent, 'HxEvent'), 'Invalid HxEvent') and HxEvent :: any;
	local Event = self.EventDestroyersMap[HxEvent] and self.OnEventDestroyedWatchers[HxEvent];
	if Event then
		self.EventDestroyersMap[HxEvent]();
		table.freeze(HxEvent);
		Event:Process(HxEvent);
		self.OnEventDestroyedWatchers[HxEvent] = nil;
	else
		if game["Run Service"]:IsStudio() then
			warn('class does not have received HxEvent \n', debug.traceback())
		end
	end
end

--[[
	Creates a new HxEvent from the HxSignal.
	
	@class HxSignal
]]
function private.create_event <T,U> (self: SelfDefF<T,U>)
	--local Event = private.new_event(self, self.Name);
	local Snapshot = HxEvent.new(function(DefinedCallOut: DefinedCallOut, ConnectionType: "Connection" | "Once", RunType: "Parallel" | "Serial") 
		local self_ = self :: HxSignal;
		return (self_:GetReactor()::Reactor)(self_,DefinedCallOut, ConnectionType, RunType)
	end, self.DefinedCallOut :: T, class.ClassName)
	local Event, EventDestroyersMap = Snapshot.Value.Event, Snapshot.Value.Destroy
	
	local self = self :: HxSignal;
	
	local HxActionEmitter = main.HxActionEmitter.new();
	HxActionEmitter.OnceAction = true;
	
	self.OnEventDestroyedWatchers[Event::any] = HxActionEmitter;
	self.EventDestroyersMap[Event::any]=EventDestroyersMap;
	return Event
end


class.__index = main.HxActionEmitter.class;
class.ClassName = main.ClassNames.HxSignal;
class.Source = script;


class.Listeners = table.freeze({}:: {Listener});
class.OnEventDestroyedWatchers = table.freeze(setmetatable({} :: {[HxEvent]: HxActionEmitter}, private.mk));
class.EventDestroyersMap = table.freeze(setmetatable({} :: {[HxEvent]: ()->()}, private.mk));


class.DefinedCallOut = error :: DefinedCallOut;

class.AddEvent = private.create_event;
class.RemEvent = private.destroy_event;

class.IsTransferConnection = main.Abstract.SelfOverride;
class.IsAlive = main.Abstract.SelfOverride;
class.SetTransferConnection = main.Abstract.SelfOverride;

class.GetReactor = main.Abstract.SelfOverride;
class.SetReactor = main.Abstract.SelfOverride;
class.GetOperator = main.Abstract.SelfOverride;
class.SetOperator = main.Abstract.SelfOverride;

class.DoCall = private.call_properties;
class.DoCallSelf = main.Abstract.ShouldOverrided;

class.Destroy = private.destroy_properties; 
class.ClearListeners = private.clear_listeners;

interface.class = class;
interface.new = private.new_event_properties;

table.freeze(class)
table.freeze(interface)
table.freeze(private)

return main:expand({HxSignal = interface})