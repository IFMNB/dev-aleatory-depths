--!strict
--!optimize 0

local main = require('./')

local shadow = require('./HxShade').Shade.new()

local private = {}
local class = {}; class.__index=main.__HxBaseProperty.class; setmetatable(class,class)
local interface = {}; interface.class=class

private.mtv={__mode='v'::'v'}
class.Source=script
class.ClassName=main.ClassNames.HxHooker
private.Meta = {}

@native
function private.Meta .__index <t0,t1> (self: t0, i: t1) : any
	debug.profilebegin(script.Name..' .__index')
	
	local shadeHook : ShadeHook = shadow:Get(self)
	local shadeParams : ShadeParams = shadow:Get(shadeHook._params)
	local result : any
	
	if shadeParams._signalbehavior then
		if shadeParams._signalbehavior == 'before' then
			result = shadeHook._at[i]
		end
	else
		result = shadeHook._at[i]
	end
	
	if private.ParamsDoVerifyState(shadeHook._params) and private.ParamsDoVerifyMod(shadeHook._params, 'index') then
		debug.profilebegin(script.Name..' .__index .ParamsDoCall')
		private.ParamsDoCall(shadeHook._params, shadeHook._at, i, nil, nil)
		debug.profileend()
	end
	
	if shadeParams._signalbehavior then
		if shadeParams._signalbehavior == 'after' then
			result = shadeHook._at[i]
		end
	end
	
	assert(shadeHook._at, '_GC error')
	debug.profileend()
	return result
end

@native
function private.Meta .__newindex <t0,t1,t2> (self: t0, i: t1, n: t2) : ()
	debug.profilebegin(script.Name..' .__newindex')
	
	local shadeHook : ShadeHook = shadow:Get(self)
	local shadeParams : ShadeParams = shadow:Get(shadeHook._params)
	
	assert(shadeHook._at,  '_GC error')
	local old = shadeHook._at[i]
	
	if shadeParams._signalbehavior then
		if shadeParams._signalbehavior == 'before' then
			shadeHook._at[i]=n
		end
	else
		shadeHook._at[i]=n
	end
	
	
	if private.ParamsDoVerifyState(shadeHook._params) and private.ParamsDoVerifyMod(shadeHook._params, 'newindex') then
		debug.profilebegin(script.Name..' .__newindex .ParamsDoCall')
		private.ParamsDoCall(shadeHook._params, shadeHook._at, i, n, old)
		debug.profileend()
	end
	
	if shadeParams._signalbehavior then
		if shadeParams._signalbehavior == 'after' then
			shadeHook._at[i]=n
		end
	end
	
	debug.profileend()
end

@native
function private.Meta .__call <t0,t1> (self: t0, ...: any) : any?
	debug.profilebegin(script.Name..' .__call')
	
	local shadeHook : ShadeHook = shadow:Get(self)
	local shadeParams : ShadeParams = shadow:Get(shadeHook._params)
	local result : any
	
	assert(shadeHook._at,'_Gc error')
	
	if shadeParams._signalbehavior then
		if shadeParams._signalbehavior == 'before' then
			result = (shadeHook._at::any)(...)
		end
	else
		result = (shadeHook._at::any)(...)
	end
	
	if private.ParamsDoVerifyState(shadeHook._params) and private.ParamsDoVerifyMod(shadeHook._params, 'call') then
		debug.profilebegin(script.Name..' .__call .ParamsDoCall')
		private.ParamsDoCall(shadeHook._params, shadeHook._at, ...)
		debug.profileend()
	end
	
	if shadeParams._signalbehavior then
		if shadeParams._signalbehavior == 'after' then
			result = (shadeHook._at::any)(...)
		end
	end
	
	
	debug.profileend()
	return result
end

private.Meta.__metatable = 'forbidden'





function private.ParamsDoVerifyState (self: HookParams)
	return (shadow:Get(self)::ShadeParams)._state == 'run'
end
function private.ParamsDoVerifyMod (self: HookParams, enum: metamodify)
	return (shadow:Get(self)::ShadeParams)._modify == enum
end
function private.ParamsDoCall (self: HookParams, ...: any)
	(shadow:Get(self)::ShadeParams)._react(...)
end










-- Creates an instance of the class. Accepts a reactor (a function that is called when an event occurs) and a modification mode (the type of event that triggers the reactor).
function private.Constructor <t0> (reactor: func?, modify: t0 | metamodify?)
	debug.profilebegin(script.Name..' .new_params')
	
	local HookParameters = {}
	HookParameters.Metamethode = modify :: t0
	
	local InstanceHookParameters = main.new(HookParameters, class) --obj.New(HookParameters, private.HookParamsClassName, nil, nil)
	
	local shade : ShadeParams = shadow:Get(InstanceHookParameters)
	shade._state = 'pause'
	shade._react = reactor or warn
	shade._modify = modify or 'index'
	
	
	assert(shadow:Get(InstanceHookParameters))
	
	debug.profileend()
	return InstanceHookParameters
end

-- Creates a react instance that calls the passed function when the event specified in the modification mode occurs.
function private:CreateHook <t0> (ForTarget: t0) : t0
	debug.profilebegin(script.Name..' .new_hook')
	
	local hook = {}
	

	local mth = {}
	mth.__iter = function ()
		return next, ForTarget
	end
	mth.__len = function ()
		return #(ForTarget::any)
	end

	for i,v in pairs(private.Meta) do
		mth[i]=v
	end
	
	setmetatable(hook,mth)
	
	local shade : ShadeHook = shadow:Get(hook)
	shade._at = ForTarget
	shade._params = (self::HookParams)
	
	-- setmetatable(shade, private.mtv) 
	-- probably we can use hooks as a interlayers.
	-- Shade anyway exists while hook exists, so why we need to clear that region?

	debug.profileend()
	return hook
end

-- Resuming operation of parameters. Does not affect proxy operation.
function private:ResumeParams ()
	local shade : ShadeParams = shadow:Get(self)
	shade._state = 'run'
end
-- Pause of parameters operation. Does not affect proxy operation.
function private:PauseParams ()
	local shade : ShadeParams = shadow:Get(self)
	shade._state = 'pause'
end

type EnterTypes = 'after' | 'before'
-- For supported types, defines the behavior of the proxy when activate reactor. 
function private:Define <t0> (SignalBehavior: EnterTypes)
	print(self, shadow)
	local shade : ShadeParams = shadow:Get(self :: t0)
	shade._signalbehavior = SignalBehavior
	return self :: t0
end

class.Resume = private.ResumeParams
class.Pause = private.PauseParams
class.Create = private.CreateHook
class.DefineBehavior = private.Define
interface.new = private.Constructor
table.freeze(class)
table.freeze(private)
table.freeze(interface)

type metamodify = 'index'|'newindex'|'call'
type states = 'run'|'pause'
type func = (self: {[any]:any}, ...any)->()
type ShadeHook = setmetatable<{_at: {[any]:any},
_params: HookParams
}, typeof(private.mtv)>
type ShadeParams = {
	_state: states,
	_react: func,
	_modify: metamodify,
	_signalbehavior: EnterTypes?
}
type HookParams = typeof(interface.new((nil::any)::func, (nil::any)::metamodify))--typeof(obj.New({}::public, private.HookParamsClassName))
export type types = {
	HookParamsSignature: HookParams,
	Public: typeof(class),
	ShadeForParams: ShadeParams,
	ShadeForHook: ShadeHook,
	ExpectedFunction: func,
	ExpectedMetamodify: metamodify,
	ExpectedEnterType: EnterTypes,
	SystemDefaultEnterType: 'before'
}

-- The HookParams class provides tools for creating proxy reactants.

return main:expand({Hooks=interface})