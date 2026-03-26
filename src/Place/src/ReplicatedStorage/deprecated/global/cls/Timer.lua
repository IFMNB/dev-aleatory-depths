local gl = require('./')
local instance = gl.Library.Hexagon.Classes.Instance()

local private = {}
local class = {}
local constr = {}

private.mt = {__index=class}
private.classname = 'Timer' :: 'Timer'

-- Creates coroutine that increments Timer.Value by +1 every wait-time.
function private:Increment (Wait: number)
	local this = (self::any)::Timer
	
	local thread = coroutine.create(function ()
		for i=this.Value, math.huge do
			task.wait(Wait)
			this.Value += 1
		end
	end)
	
	coroutine.resume(thread)
	return thread
end
-- Creates coroutine that substracts Timer.Value by -1 every wait-time.
function private:Substract (Wait: number)
	local this = (self::any)::Timer

	local thread = coroutine.create(function ()
		for i=this.Value, math.huge do
			task.wait(Wait)
			this.Value -= 1
		end
	end)

	coroutine.resume(thread)
	return thread
end

function private.new ()
	local this = setmetatable({}, private.mt)
	this.Value = 0
	
	local TimerInstance = instance.New(this, private.classname)
	
	return TimerInstance
end

class.RepeatIncrement = private.Increment
class.RepeatSubstract = private.Substract
constr.New = private.new

type Timer = typeof(private.new())

return constr :: typeof(constr) & {
	_Typesolver: {
		
	}
}