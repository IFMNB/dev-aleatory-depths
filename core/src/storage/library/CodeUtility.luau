local private = {};
local interface = {};

@native
function private.random ()
    local b = tick()
    local str = {}
    local t = os.clock()
    for i=1, math.random(32,128) do
        math.randomseed((i/t)-t+math.random(1,tick()))
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

interface.RandomStr = private.random;

return interface