local gl = require('./')

local instance = gl.Library.Hexagon.Classes.Instance()
local shadow = gl.Library.CodeBox.Tables.Shadow()

local private = {}
local public = {}
local class = {}

private.Classname = 'InteractiveValue' :: 'InteractiveValue'
private.mt = {__index=public}
type InterValue = typeof(private.new(0))

-- Creates a new InterValue instance. 
function private.new (value: number)
	local this = setmetatable({Value=value}, private.mt)
	local self = instance.New(this,private.Classname)

	local shade = shadow.New(self)
	shade._origin = self
	shade._mods = {}

	return self
end

function private.cyclemodifiers (self: InterValue, startvalue: number?, ...:any?)
	local this = self :: InterValue
	local shade : shade = shadow.Get(this)

	local val : number
	for i,mod in shade._mods do
		val = mod(this.Value, val or startvalue or this.Value, ...)
	end

	return val
end

-- Pushes a new value to the InterValue instance, activating all modifiers. 
function private:Push (value: number?, ...: any?)
	local this = self :: InterValue
	local shade : shade = shadow.Get(this)
	shade._origin.Value = private.cyclemodifiers(this, value, ...)
	return this
end
-- Smoothly interpolates the InterValue instance to a new value. 
function private:Interpolate (value: number?, ...: any?)
	local this = self :: InterValue
	local shade : shade = shadow.Get(this)
	local result = private.cyclemodifiers(this, value, ...)

	local con0 : RBXScriptConnection
	con0 = game["Run Service"].Heartbeat:Connect(function(deltaTime: number) 
		if this.Value == result then con0:Disconnect() return end
		shade._origin.Value = math.lerp(shade._origin.Value, result, deltaTime)
	end)

	return this
end

type mod = (value: number, newvalue: number, ...any?) -> number
-- Adds a modifier to the InterValue instance. 
function private:AddMod (mod: mod)
	local this = self :: InterValue
	local shade : shade = shadow.Get(this)
	table.insert(shade._mods, mod)
	return this
end
-- Removes a modifier from the InterValue instance. 
function private:RemMod (mod: mod)
	local this = self :: InterValue
	local shade : shade = shadow.Get(this)
	table.remove(shade._mods, table.find(shade._mods, mod))
	return this
end

type shade = {
	_origin: typeof(instance.New(setmetatable({Value=0}, private.mt),private.Classname)),
	_mods: {mod}
}

public.Push = private.Push
public.Interpolate = private.Interpolate
public.AddMod = private.AddMod
public.RemMod = private.RemMod
class.New = private.new

table.freeze(public)
table.freeze(private)
table.freeze(class)

return class