local CollectionService = game:GetService('CollectionService')

local private = {};
local interface = {};

@native
function private.random_str ()
    local b = tick()
	local str = {}
	
	local t = os.clock()
	
	
	for i=1, 8 do
		local str_c = #str
		local str_n = string.byte(tostring(str), math.random(1, str_c > 0 and str_c or 1))
        math.randomseed((i/t)-t+math.random(1,tick())+str_n)
        local i0 = i/2
        table.insert(str, 
            math.round(i0)==i0 and tostring(math.random(1,b)) or string.char(math.random(64,125)) 
        )
        local i1 = i/3
        if math.round(i1)==i1 then
           table.insert(str, '-') 
        end
        t+=i^3
    end
    
    return table.concat(str)
end

function private.is_parallel_context ()
	local state = pcall(function(...) 
		script.Parent = script.Parent
	end)
	
	return not state
	-- может завтра в task будет лежать метод проверки контекста?
end

function private.call_in_sync_context (f, ...)
	if private.is_parallel_context() then
		return private.swap_context(f, ...)
	else
		return f(...)
	end
end

function private.call_in_parallel_context (f, ...)
	if private.is_parallel_context() then
		return f(...)
	else
		return private.swap_context(f, ...)
	end
end

function private.swap_context (f: (...any)->any, ...)
	local r0
	if private.is_parallel_context() then
		task.synchronize()
		r0 = f(...)
		task.desynchronize()
	else
		task.desynchronize()
		r0 = f(...)
		task.synchronize()
	end
	return r0
end

function private.set_tag_identity (this: Instance, Identity: string?)
	Identity = Identity or private.random_str()
	this:AddTag(Identity)
	return Identity
end

function private.get_from_identity (Identity: string) : Instance?
	return if Identity == '' or Identity == nil then nil else CollectionService:GetTagged(Identity)[1]
end

interface.RandomStr = private.random_str;
interface.GetInstanceFrom = private.get_from_identity;
interface.GetInstanceIdentity = private.set_tag_identity;

interface.IsParallelContext = private.is_parallel_context;
interface.DoInvertedContextCall = private.swap_context;
interface.DoCallContextParallel = private.call_in_parallel_context;
interface.DoCallContextSync = private.call_in_sync_context;


return interface