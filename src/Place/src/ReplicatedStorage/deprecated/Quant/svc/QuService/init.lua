local cor = require('../plg/cor')


local private = {}
local public = {}
local class = {}

type DefaultFunc = ()->()

type OnInitFunc = DefaultFunc
type OnStartFunc = DefaultFunc
type OnKilledFunc = DefaultFunc
type OnErrorFunc =  ( -- On every errors thread that executes SelfWork stops and awaited signal from this function
	e0: OnXErrorFunctions,
	DoContinue: DefaultFunc, -- Continue execution
	DoKill: DefaultFunc --[[
			Definally kills service
			
			@param1 == 'OnInit' -> that function cancel OnInit thread
		
		
		]]
)->()

type OnXFunctions = 'OnInit' | 'OnStart' | 'OnKilled' | string
type OnXErrorFunctions = OnXFunctions | 'OnSelfWork'

-- TODO

type QuServiceSignature = typeof(private:New(''::string,{}))
type QuService <t0,t1> = typeof(private:New(''::t0,{}::t1))
type QuServiceData = {
	OnInit: OnInitFunc?, -- That function executes as a first step to maintance service and setup all data inside to default params.
	OnStart: OnStartFunc?, -- That function executes when every services already used OnInit functions. This is asynchronous functions that AUTOMATICALLY starts SelfWork.
	OnKilled: OnKilledFunc?, -- That function executes only when called manually or when service got critical error.
	OnError: OnErrorFunc|typeof(warn),
	SelfKill: DefaultFunc, -- Kills service, so the coroutine that executes SelfWork stops now.
	SelfDestroy: DefaultFunc, -- Destroys service and clears all data from this class about this service.
	SelfWork: DefaultFunc, -- Default service worker function. Please do not use that function manually if you dont know what are you doing.
	
	ServiceThreads: {
		SelfWorker: thread
	},
	
	ServiceStats: {
		IsNeverStarts: boolean, -- Service never started
		IsRunning: boolean, -- Service currently is running
		IsStarted: boolean, -- Service already started, but IsRunning may be false
		IsInit: boolean, -- Service already inited
		IsKilled: boolean, -- Service currently dead, you should call OnInit() and OnStart() again to restart him
		
		
		RBXConnections: {
			{Event:RBXScriptSignal,F: (...any)->(), Type: 'Connect'|'Once'}
		},
		ErrorsCount: number,
		Errors: {string}
	}
}

-- Services

private.serviceclassname = 'QuService' :: 'QuService'
private.errors = {}
private.errors.ServiceNotExists = 'QuService %q does not exist' :: 'QuService %q does not exist'
private.errors.ServiceAlreadyRegistered = 'QuService %q is already registered' :: 'QuService %q is already registered'
private.errors.FunctionAlreadyExists = 'Function %q already exists in %s, maybe you have leaks?' ::'Function %q already exists in %s, maybe you have leaks?'

private.protected = {}
private.protected.ServicesData = {} :: {[QuServiceSignature]: QuServiceData}
private.cash = setmetatable({}:: {[string]: QuServiceSignature}, {__mode='v'})

function private.__tostring ()
	return private.serviceclassname
end

function private.GetQuServiceData <t0,t1> (QuService: QuService<t0,t1>) : QuServiceData
	return assert(private.protected.ServicesData[QuService], string.format(private.errors.ServiceNotExists, tostring(QuService.Name)))
end

-- Used in cases where we need to properly control service execution. 
function private.ThreadWrapper (name: OnXErrorFunctions, OnError: OnErrorFunc, F: DefaultFunc)
	local thread = coroutine.running()
	cor.AsyncWait(function(OnEnd: () -> (), ...) 
		F();
		return OnEnd()
	end, function(errmsg: string, DoContinue: () -> (), DoClose: () -> ()) 
		return OnError(name, DoContinue, DoClose)
	end)
	
	return
end

function private.ThreadWrapperAsync (name: OnXErrorFunctions, OnError: OnErrorFunc, F: DefaultFunc)
	cor.Async(function(...) 
		F()
	end, function(errmsg: string) 
		return OnError(name,
			function ()
				private.ThreadWrapperAsync(name, OnError, F)
			end,
			function ()
				coroutine.close(coroutine.running())
			end)
		end
	)
	
	return
end


function private:RegistryInit <t0,t1> (QuService: QuService<t0,t1>, OnInit: OnInitFunc)
	local QuServiceData = private.GetQuServiceData(QuService)
	assert(not QuServiceData.OnInit::unknown, string.format(private.errors.FunctionAlreadyExists, 'OnInit', tostring(QuService.Name)))
	
	local f0 = function ()
		local QuServiceStats = QuServiceData.ServiceStats
		QuServiceStats.IsInit = false
		QuServiceStats.IsRunning = false
		QuServiceStats.IsStarted = false
		QuServiceStats.IsKilled = false
		
		private.ThreadWrapper('OnInit', QuServiceData.OnError, OnInit)
		
		QuServiceStats.IsInit = true
		return
	end
	
	QuServiceData.OnInit = f0
	
	return class
end

function private:RegistryStart <t0,t1> (QuService: QuService<t0,t1>, OnStart: OnStartFunc)
	local QuServiceData = private.GetQuServiceData(QuService)
	assert(not QuServiceData.OnStart::unknown, string.format(private.errors.FunctionAlreadyExists, 'OnStart', tostring(QuService.Name)))

	local f0 = function ()
		private.ThreadWrapper('OnStart', QuServiceData.OnError, OnStart)
		
		QuServiceData.ServiceStats.IsStarted = true
		QuServiceData.ServiceStats.IsRunning = true
		
		private.ThreadWrapperAsync('OnSelfWork', QuServiceData.OnError, QuServiceData.SelfWork)
		
		return		
	end

	QuServiceData.OnStart = f0
	
	return class
end

function private:RegistryKilled <t0,t1> (QuService: QuService<t0,t1>, OnKilled: OnKilledFunc)
	local QuServiceData = private.GetQuServiceData(QuService)
	assert(not QuServiceData.OnKilled::unknown, string.format(private.errors.FunctionAlreadyExists, 'OnKilled', tostring(QuService.Name)))

	local f0 = function ()
		private.ThreadWrapper('OnKilled', QuServiceData.OnError, OnKilled)
		
		QuServiceData.ServiceStats.IsKilled = true
		return		
	end

	QuServiceData.OnKilled = f0
	
	return class
end



function private:UnRegistryAlt <t0,t1> (QuService: QuService<t0,t1>, Name: OnXFunctions)
	assert(Name == 'OnInit' or Name == 'OnStart' or Name == 'OnDestroyed', 'Unknown name')
	local QuServiceData = private.GetQuServiceData(QuService);
	(QuServiceData::any)[Name] = nil;
	return class;
end

function private:Remove <t0,t1> (QuService: QuService<t0,t1>)
	private.protected.ServicesData[QuService]=nil
	return class
end

function private:Get <t0> (Name: t0) : QuService<t0,{}>
	local cashed = private.cash[Name]
	return cashed :: any
end


function private.NewData (QuService: QuServiceSignature)
	local QuServiceData : QuServiceData = {} :: any
	QuServiceData.OnInit = nil
	QuServiceData.OnStart = nil
	QuServiceData.OnKilled = nil
	QuServiceData.OnError = warn
	QuServiceData.SelfKill = nil :: any
	QuServiceData.SelfWork = nil :: any
	QuServiceData.SelfDestroy = nil :: any
	QuServiceData.ServiceStats = {} :: any
	QuServiceData.ServiceStats.IsInit = false
	QuServiceData.ServiceStats.IsStarted = false
	QuServiceData.ServiceStats.IsKilled = false
	QuServiceData.ServiceStats.IsRunning = false
	QuServiceData.ServiceStats.IsNeverStarts = true
	QuServiceData.ServiceThreads = {} :: any
	QuServiceData.ServiceThreads.SelfWorker = nil :: any
	
	private.protected.ServicesData[QuService] = QuServiceData
	
	return QuServiceData
end

function private.NewService <t0,t1> (Name: t0, ServiceData: t1)
	local QuService = table.clone(public)
	setmetatable(QuService::unknown, {
		__index=ServiceData,
		__metatable = private.serviceclassname,
		__tostring = private.__tostring
	})

	QuService.Name = Name :: t0

	return QuService :: typeof(QuService) & t1
end


function private:New <t0,t1> (Name: t0 & string, ServiceData: t1)
	local QuService = private.NewService(Name, ServiceData)
	local QuServiceData = private.NewData(QuService)
	
	private.cash[Name] = QuService
	
	return QuService
end

class.New = private.New
class.Remove = private.Remove
class.Get = private.Get
class.All = private.protected.ServicesData

class.RegOnInit = private.RegistryInit
class.RegOnStart = private.RegistryStart
class.RegOnDestroyed = private.RegistryKilled
class.UnReg = private.UnRegistryAlt

return class