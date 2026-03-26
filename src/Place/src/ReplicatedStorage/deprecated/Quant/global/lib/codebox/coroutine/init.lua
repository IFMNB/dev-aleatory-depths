--!strict

local private = {}
local plugin = {}

-- Creates a async coroutine and executes it. Used xpcall.
function private.CreateAsync (func: func, handler: handler?, ...: any)
	return xpcall(coroutine.wrap(func),handler or warn,...)
end
-- Creates a async coroutine and executes it. While async coroutine does not called OnEnd function, main thread will be waiting. 
function private.CreateAsyncWait (func: asyncwait, handler: handler2?, ...: any)
	assert(coroutine.isyieldable(), 'This procedure can be only called from coroutine that can be yielded.')
	
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

-- К текущей коррутине скрипта подключится функция, которая сработает при смерти коррутины. @param3 - всегда время жизни корутины до ее смерти. Остальное variable.
function private.OnShutdown (f: (time1: number ,...any)->(), ...: any)
	local time0 = os.clock()
	local thread0 = coroutine.running()
	local thread1 = coroutine.create(function(...)
		while task.wait() do
			if coroutine.status(thread0) == 'dead' then
				f(os.clock()-time0, ...)
				break	
			end
		end

		return
	end)
	coroutine.resume(thread1)
	return thread1
end

-- Функция получает дополнительное замыкание, которое функционирует начиная с времени начала работы функции. Замыкания возвращает разницу времени с начала работы функции с точностью os.clock.
function private.Timestamp <t0...> (f: (EndTimestamp: ()-> number, ...any) -> t0..., ...: any ) : t0...
	local clock = os.clock()
	return f(function(): number return clock-os.clock() end, ...)
end

plugin.Autonomous = private.CreateAsync
plugin.Async = private.CreateAsyncWait
plugin.OnShutdown = private.OnShutdown
plugin.WithTimestamp = private.Timestamp

type func = (...any)->any
type handler = (errmsg: string)->()
type handler2 = (errmsg: string, DoContinueCoroutine: onend, DoCloseCoroutine: onend)->()
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