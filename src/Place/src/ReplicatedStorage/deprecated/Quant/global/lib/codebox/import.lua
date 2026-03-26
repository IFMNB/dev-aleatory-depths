--!strict

local private = {}
local public = {}

private.err = 'Unstable function call'

function private.DoProtectedGetCycle (func: (...any)->any, tryattempts: number, timewait: number, ...: any) : any
	local count = tryattempts
	local st, r

	repeat
		st, r = xpcall(func, function(a0) warn(a0) end,...)

		if st then
			return r
		else
			warn(private.err)
		end

		count-=1
		task.wait(timewait)
	until count > 0

	return private.UnhandledDefaultException(r, debug.traceback('t'), count, tryattempts);
end


function private.VerifyReceivedDataFromTrySection (catch: any, ...: any)
	local res = private.DoProtectedGetCycle(...)
	if typeof(res) == catch then
		return res
	else
		warn(private.err)
		task.wait(1)
		return private.VerifyReceivedDataFromTrySection(catch, ...)
	end 
end
-- Execute function and return result. If failed, tryes again before get result.
function private.DoProtectedForeverCycle (func: func, ...: any) : unknown
	local st,r = xpcall(func, function(a0) warn(a0) end, ...)
	if st then
		return r
	else
		warn(private.err)
		task.wait(1)
		return private.DoProtectedForeverCycle(func, ...)
	end
end

function private.UnhandledDefaultException (...)
	warn(...)
	error(private.err)
end


type cases =  {
	default: ((...any)->any?)|any?,
	[any]: ((...any)->any?)|any
}

function private.ReturnValueFromSwitchCases (value: any, case: cases) : any
	return case[value]
		or case.default
		or case.Default
		or private.UnhandledDefaultException(value, case, debug.traceback())
end

type func = (...any)->unknown

-- Execute function and return result. If failed, tryes again before get result.
function public.safe (func: func, ...: any) : unknown
	return private.DoProtectedForeverCycle(func, ...)	
end
-- Executes function from try and verify received data type. If verify failed, tryes to execute it again. Return result of function with this type. 
function public.catch <type> (catch: type, func: (...any)->any, try: number, timewait: number, ...: any) : any
	return private.VerifyReceivedDataFromTrySection(catch, func, try, timewait, ...)
end
-- Tryes to execute function, if it fails, repeats it until it succeeds or timeout is over. Return result of function or error.
function public.try (func: (...any)->any, try: number, timewait: number, ...: any) : any
	return private.DoProtectedGetCycle(func, try, timewait, ...)
end
-- Switch returns value from cases or default case.
function public.switch (value: any, case: cases) : any
	return private.ReturnValueFromSwitchCases(value, case)
end

export type self = typeof(public)
export type ancestors = self
type inject = {
	_TypeCheck: {
		switchCases: cases
	}
}

return public :: typeof(public)&inject