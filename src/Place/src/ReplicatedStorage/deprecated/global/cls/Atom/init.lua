local gl = require('./')

local hxc = gl.Library.Hexagon.Classes
local ob = hxc.Object()
local ev = hxc.Events()

local shadow = gl.Library.CodeBox.Tables.Shadow()

local private = {}
local pub = {}
local class = {}

private.mt = {__index=pub}

type shade = typeof(private.new_misc(nil::any))
function private.new_misc (atom: atom)
	type shade = {
		_a: Actor,
		_w: Script,
		_e: BindableEvent
	}
	
	local actor = Instance.new('Actor')
	actor.Parent=script
	local worker : Script = script.server:Clone()
	worker.Parent=actor
	local event = Instance.new('BindableEvent')
	event.Parent=worker
	worker.Enabled=true
	event.Event:Wait()
	
	local shade : shade = shadow.New(atom)
	shade._a=actor
	shade._w=worker
	shade._e=event
	
	return shade
end

type atom = typeof(private.new_atom())
private.evname = 'AtomicEvent'::'AtomicEvent'
function private.new_atom ()
	local e0,c0 = ev.new(private.evname)
	local base = {}
	
	base.Result = nil :: unknown | '*error*'
	base.OnResultEvent = e0
	setmetatable(base, private.mt)
	
	local atom = ob.New(base, 'Atom' :: 'Atom')
	
	return atom, c0
end
-- Создает Атом. Он должен выполнять параллельные операции вне основного потока
function private.new ()
	local atom, c0 = private.new_atom()
	local misc = private.new_misc(atom)
	
	misc._e.Event:Connect(function(...) 
		atom.Result = ...
		c0(...)
	end)
	
	return atom
end


type fire = 'Sync'|'DSync'
function private.fire (atom: atom, to: fire, ...)
	local shade : shade = shadow.Get(atom)
	shade._a:SendMessage(to, ...)
end

-- Вызывает фрагмент кода последовательно.
function private:sync (Code: string)
	return private.fire(self::atom,'Sync',Code)
end
-- Вызывает фрагмент кода параллельно.
function private:parr (Code: string)
	return private.fire(self::atom,'DSync',Code)
end


pub.Sync = private.sync
pub.Atom = private.parr
class.new = private.new

return class