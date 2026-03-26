local cor = require('./')

local private = {}
local plugin = {}

-- Waits for a child to be added to a parent. Returns if it exists. Yields.
function private.WaitForChildClass <t0> (object: Instance, ClassName: string&t0, timeout: number?)
	local target : typeof(Instance.new(ClassName::t0))
	local mainthread = coroutine.running()
	local thread : thread?
	local thread2f : typeof(cor._typecheck.onend)?
	local thread2 : thread?
	local con0 : RBXScriptConnection?
	
	if timeout then
		thread = task.spawn(function ()
			task.wait(timeout)
			if not target then
				if thread2 then coroutine.close(thread2) end
				if con0 then con0:Disconnect() end
				if thread2f then thread2f() end
				coroutine.resume(mainthread)
			end
		end)	
	else
		thread = task.spawn(function ()
			task.wait(5)
			if not target then
				warn(string.format('WaitForChildOfClass for %s may be yielding too much. Maybe your %q is not valid?', object.Name, ClassName))
			end
		end)
	end
	
	cor.AsyncWait(function(OnEnd: () -> (), ...) 
		assert(Instance.new(ClassName), 'Invalid class name'):Destroy()
		thread2f = OnEnd
		thread2 = coroutine.running()
		
		target = object:FindFirstChildOfClass(ClassName)
		if not target then
			con0 = object.ChildAdded:Connect(function(child: Instance) 
				if child:IsA(ClassName) then
					target = child;
					(con0::RBXScriptConnection):Disconnect()
					return OnEnd()
				end
			end)
		else
			return OnEnd()
		end
	end)
	
	if thread then
		task.cancel(thread)
	end
	
	return target
end

plugin.WaitForChildOfClass = private.WaitForChildClass

return plugin