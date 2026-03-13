local private = {};
local interface = {};

@native
function private.random ()
    local b = tick()
    local str = {}
	local t = os.clock()
	local str_n = string.byte(tostring(str))
    for i=1, 8 do
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

interface.RandomStr = private.random;
interface.IsParallelContext = private.is_parallel_context;

return interface