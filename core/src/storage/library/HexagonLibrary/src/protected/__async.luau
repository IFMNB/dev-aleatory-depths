local private = {}
local interface = {}

type F <T, U...> = (...T)->U...
type Fc <Y, I...> = (ResumeThread: (...any)->(), ...any)->() -- broken

-- Yields until the ResumeThread is called. Return value that goes from the ResumeThread.
function private.coroutine_async_F_controllable <U,T,I...> (F: Fc<T,I...>, ...: U) : any
	local thread = coroutine.running()
	local context = debug.traceback('Backtrace: ')
	local cor = coroutine.create(function(...) 
		local watch = interface.SyncWatchEnd(5);
		
		local open
		local state, result = pcall(F, function (...)
			open = true
			task.cancel(watch);
			task.spawn(thread, ...);
			return;
		end, ...)
		
		if not state and not open then
			coroutine.close(thread)
			error(string.format('Asynchronous function got exception: %q with previous context %s', tostring(result), context))
		end
		
		return;
	end)
	
	task.defer(cor)
	return coroutine.yield()
end

-- Returns task that watches the coroutine for the given time. If the coroutine is still running after the given time, it will call the function or warn.
function private.coroutine_watch_end <T, U...> (wait: number?, F: F<T,U...>?)
	local thread = coroutine.running()
	local context = debug.traceback('Backtrace: ')
	return task.spawn(function ()
		task.wait(wait)
		if coroutine.status(thread) ~= 'dead' then
			if F then
				F()
			else
				warn('Watched coroutine still running, did you forget to close her?', context)
			end
		end
	end)
end

-- Yields until the function is finished. Return value that goes from the function. Throws exception if function or main coroutine got error.
function private.coroutine_async_F <T, U...> (F: F<T,U...>, ...: any) : U...
	local thread = coroutine.running()
	local context = debug.traceback('Backtrace: ')
	local cor = coroutine.create(function(...) 
		interface.SyncWatchEnd(5)
		local state, result = pcall(F :: any, ...)
		
		if not state then
			coroutine.close(thread)
			error(string.format('Asynchronous function got exception: %q with previous context %s', tostring(result), context))
		end

		local state, e0 = coroutine.resume(thread,result)
		if not state then
			error(string.format('Coroutine, that runned from asynchronous context, got exception: %q with %s',tostring(e0), context))
		else
			return e0
		end
	end)
	task.defer(cor)
	return coroutine.yield()
end

interface.AsyncControll = private.coroutine_async_F_controllable;
interface.Async = private.coroutine_async_F;
interface.SyncWatchEnd = private.coroutine_watch_end;

return interface 