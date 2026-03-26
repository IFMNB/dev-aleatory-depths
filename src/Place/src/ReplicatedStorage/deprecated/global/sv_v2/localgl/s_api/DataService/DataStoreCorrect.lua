local http = game:GetService('HttpService')

local private = {}
local module = {}

type datasave = {[string]:{datasave|number|string|boolean|buffer}}
private.data={}


function private.assert_name (name)
	local t0 = typeof(name)
	assert(t0 == 'string', 'Name must be a string')
end
function private.assert_value (value)
	local t0 = typeof(value)
	if t0 == 'table' then
		for i,v in value do
			private.assert_value(v)
		end
	else
		assert(t0 == 'number' or t0 == 'string' or t0 == 'boolean' or t0 == 'buffer', 'Value must be a table, number, string, boolean or buffer')
	end
end
function private.wait_rand ()
	local t0 = math.random(0,10) / math.random(10,100)
	task.wait(t0)
end
function private.error_rand ()
	local t0 = math.random(1,1000)
	if t0<100 then
		error('DataStore is down')
	end
end

function private.GetAsync (to: DataStore, name: keyof<datasave>)
	private.assert_name(name)
	private.error_rand()
	private.wait_rand()
	
	return private.data[to][name]
end

function private.SetAsync (to: DataStore, name: keyof<datasave>, value: index<datasave,keyof<datasave>>)
	private.assert_name(name)
	private.assert_value(value)
	private.wait_rand()
	private.error_rand()
	
	if not private.data[to] then
		private.data[to] = {}
	end
	
	
	private.data[to][name]=value
end

return module