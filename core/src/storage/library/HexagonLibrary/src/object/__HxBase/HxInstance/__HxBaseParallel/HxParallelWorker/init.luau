local main = require('./')

local run = game:GetService('RunService')

local private = {};
local class = {};
class.__index=main.__HxBaseParallel.class;
setmetatable(class,class);
local interface = {};
interface.class=class;

local shade = main.Shade.new()

type HxParallelWorker = typeof(class)



-- Implements a parallel worker, based on the loadstring() function.
function private.new ()
	assert(run:IsServer(), 'HxParallelWorker can only be used on server.')
	assert(interface.enabled, 'HxParallelWorker cannot function if loadstring() is disabled.')
	
	local Actor = Instance.new('Actor')
	local Event = Instance.new('BindableEvent')
	local Worker = script.server:Clone()
	
	Actor.Parent=class.Source
	Event.Parent=Actor
	Worker.Parent=Actor
	Worker.Enabled=true
	Event.Event:Wait()
	
	local this = main.HxInstance.new({
		Worker = Actor,
		Active = false,
	},class)
	
	Event.Event:Connect(function(...) 
		this.Result = ...
	end)
	
	shade:Set(Actor,this)
	Actor.Destroying:Once(function() shade:Set(Actor,nil) end)
	
	return this
end
-- Returns a parallel worker instance, or nil if it does not exist.
function private.get (Actor: Actor) : HxParallelWorker?
	return shade:Get(Actor)
end
-- Yields until the parallel worker finishes executing. Returns the result of the parallel worker imidiately, - access to self.Result is not safe.
function private:wait ()  : typeof(class.Result)
	local self = self :: HxParallelWorker
	local event : BindableEvent = assert(self.Worker:FindFirstChildOfClass('BindableEvent'))
	local r0  = event.Event:Wait()
	self.Active = false
	return r0
end

function private.fire (this: HxParallelWorker, code: string, env: string?, channel: 'DSync'|'Sync')
	assert(not this.Active, 'Cannot execute while already executing')
	this.Active = true
	this.Worker:SendMessage('Sync',code,env)
	return this:WaitResult()
end

-- Executes synchronously on the parallel worker and waits for the result.
function private:exe (Code: string, Env: string?)  : typeof(class.Result)
	return private.fire(self::HxParallelWorker,Code,Env,'Sync')
end
-- Executes parallelly on the parallel worker and waits for the result.
function private:parallel (Code: string, Env: string?)  : typeof(class.Result)
	return private.fire(self::HxParallelWorker,Code,Env,'DSync')
end

class.Worker = (nil::any) :: Actor
class.WaitResult = private.wait
class.Do = private.exe
class.DoParallel = private.parallel
class.Source=script
class.ClassName=main.ClassNames.HxParallelWorker
interface.new = private.new
interface.get = private.get
interface.enabled = pcall(loadstring,'',nil)

table.freeze(interface)
table.freeze(class)
table.freeze(private)

return main:expand({ParallelWorker = interface})