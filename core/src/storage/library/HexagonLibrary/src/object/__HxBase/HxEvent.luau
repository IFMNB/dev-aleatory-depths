local main = require('./');

local private = {};
local class = {}; setmetatable(class,class);
local interface = {};

type HxConnection = typeof(require('./HxConnection').HxConnection.new())
type ConType = 'Connection'|'Once'
type RunType = 'Parallel'|'Serial'
type ActionType = 'JustConnection' | 'Wait'
type DefaultFunction<T=any,U=any> = (...U)->T
type FReactor = (DefaultFunction: DefaultFunction, ConnectionType: ConType, RunType: RunType, ActionType: ActionType)->HxConnection
type HxEvent <Reacor_ = FReactor> = typeof(private.new(nil::Reacor_))
type DeadWatch = (HxEvent: HxEvent)->()

--[[
	Creates a new HxEvent. Also returns a function that destroys the event.

	Please note: despite the fact that HxEvent instances are nominally always equal in one way or another,
	due to the contravariance of functions and the structural type of event verification,
	it is impossible to support this type of instance at the RBXScriptSignal level and not lose the typical markup for events.

	@class HxEvent
	@return Instance (@P HxEvent), Function
]]
function private.new <T,U> (Reactor: FReactor, DefaultFunction: T|DefaultFunction?, Name: U?)
	local this = {}
	local labmda : HxEvent
	local watchers = {} :: {DeadWatch}
	local alive = true
	local result
	
	this.DefaultFunction = (DefaultFunction or class.DefaultFunction) :: T
	
	--[[
		Returns a HxConnection that represents the connected function.
		
		If the event is destroyed, the connection will be disconnected.
		
		@class HxEvent
		@return Instance (@P HxConnection (Connection))
	]]
	function this:Connect (Function: T?) : HxConnection
		return alive and Reactor(Function or this.DefaultFunction, 'Connection', 'Serial', 'JustConnection') or error('Event is dead')
	end
	
	--[[
		Returns a HxConnection that represents the connected function.
		
		If the event is destroyed, the connection will be disconnected.
		The function will be disconnected once the event is fired.
		
		@class HxEvent
		@return Instance (@P HxConnection (Once))
	]]
	function this:Once (Function: T?) : HxConnection
		return alive and Reactor(Function or this.DefaultFunction, 'Once', 'Serial', 'JustConnection') or error('Event is dead')
	end
	
	--[[
		Returns a HxConnection that represents the connected function.
		
		If the event is destroyed, the connection will be disconnected.
		
		@class HxEvent
		@return Instance (@P HxConnection (ConnectionParallel))
	]]
	function this:ConnectParallel (Function: T?) : HxConnection
		return alive and Reactor(Function or this.DefaultFunction, 'Connection', 'Parallel', 'JustConnection') or error('Event is dead')
	end
	
	--[[
		Returns a HxConnection that represents the connected function.
		
		If the event is destroyed, the connection will be disconnected.
		The function will be disconnected once the event is fired.
		
		@class HxEvent
		@return Instance (@P HxConnection (OnceParallel))
	]]
	function this:OnceParallel (Function: T?) : HxConnection
		return alive and Reactor(Function or this.DefaultFunction, 'Once', 'Parallel', 'JustConnection') or error('Event is dead')
	end
	
	--[[
		Connects to the event death.
		
		Returns a function that disconnects the connection.
		
		@class HxEvent
		@return Function
	
	]]
	function this:WatchDeath (Function: (HxEvent: typeof(assert(result)))->())
		if not alive then error('Event is dead') end
		
		table.insert(watchers,Function)
		
		-- Removes the function from the event.
		return function ()
			table.remove(watchers, table.find(watchers,Function))
		end
	end
	
	
	this.Alive = alive;
	this.Name = Name;
	
	--[[
		Yields the thread until the event is fired.
	
		@yields
		@class HxEvent
		@return ...unknown
	]]
	function this:Wait () : ...unknown
		local thread = coroutine.running()
		assert(alive, 'Event is dead')
		task.defer(function ()
			Reactor(function(...) coroutine.resume(thread, ...) return ... end, 'Once', 'Serial', 'Wait')
		end)
		return coroutine.yield()
	end
	
	result = main.new(this, class)
	labmda = result
	
	--[[
		Destroys the event.
	
		@class HxEvent
		@return ()
	]]
	local function labmda_disc ()
		alive = nil;
		this.Alive = false;
		table.freeze(this);
		for i,v in watchers do
			task.spawn(v, result :: any)
		end
		watchers = nil
	end
	
	return result :: typeof(assert(result)), labmda_disc
end

class.__index = main.__HxBase.class;
class.ClassName = main.ClassNames.HxEvent;
class.Source = script;
class.DefaultFunction = (warn::any) :: DefaultFunction;
class.Connect = main.Abstract.SelfNotImplemented;
class.Once = main.Abstract.SelfNotImplemented;
class.ConnectParallel = main.Abstract.SelfNotImplemented;
class.OnceParallel = main.Abstract.SelfNotImplemented;
class.WatchDeath = main.Abstract.SelfNotImplemented;
class.Wait = main.Abstract.SelfNotImplemented;

local instance, killinstance = private.new(nil::any, nil::any, nil::any);
killinstance();table.freeze(instance);

interface.class = class;
interface.instance = instance
interface.new = private.new;

return main:expand({HxEvent = interface})