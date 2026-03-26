local actor : Actor = assert(script.Parent:IsA('Actor') and script.Parent, 'ParallelService worker must be a Actor')
local event : BindableEvent = assert(actor:FindFirstChildOfClass('BindableEvent'), 'BindableEvent not found')

local function new_func (a0,a1)
	local f = loadstring(a0,a1)
	assert(f, 'Code does not return a function')
	return f
end

local function exe (f)
	local state, out = pcall(f)
	
	if not state then
		warn(out)
		return '*error*'
	else
		return out
	end
end

actor:BindToMessage('Sync', function (code: string, env: string?)
	local f = new_func(code,env)
	local out = exe(f)
	event:Fire(out)
end)
actor:BindToMessageParallel('DSync', function (code: string, env: string?)
	local f = new_func(code,env)
	task.desynchronize()
	local out = exe(f)
	event:Fire(out)
end) 