--!strict

local private = {}
local plugin = {}

-- Creates a async coroutine and executes it. Used xpcall.
function private.CreateAsync (func: func, handler: handler?, ...: any)
	return xpcall(coroutine.wrap(func),handler or warn,...)
end
-- Creates a async coroutine and executes it. While async coroutine does not called OnEnd function, main thread will be waiting. 
function private.CreateAsyncWait (func: asyncwait, handler: handler2?, ...: any)
	local thread = coroutine.running()
	local f = function() coroutine.resume(thread) return end
	local thread2 = coroutine.create(function(...)
		xpcall(func :: any,
			handler and function (a0)
				(handler::handler2)(a0,f, function()
					coroutine.close(thread)
				end) 
			end or warn,
			f,...
		)
	end)
	
	task.defer(thread2)
	coroutine.yield()
	
	return 
end


plugin.Async = private.CreateAsync
plugin.AsyncWait = private.CreateAsyncWait

type func = (...any)->any
type handler = (errmsg: string)->()
type handler2 = (errmsg: string, DoContinue: onend, DoClose: onend)->()
type asyncwait =(OnEnd: onend, ...any)->()
type onend = ()->()

return plugin :: typeof(plugin) & {
	_typecheck: {
		func: func,
		handler: handler,
		asyncwait: asyncwait,
		onend: onend,
	}
}