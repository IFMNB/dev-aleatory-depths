local private = {};
local interface = {};

-- Returns the path of the given instance, or an empty string if the argument is not an instance.
@deprecated
function private.GetPath (to: Instance)
	if not game.IsA(to, 'Instance') then return '' end
	
	local list = {} :: {string}
	local this : Instance? = to.Parent
	table.insert(list, to.Name)
	while this do
		table.insert(list,this.Name)
		this = this.Parent
	end
	
	local path = '@game'
	for i=1, #list  do
		local i2 = #list-i
		if i2 == 0 then return path end
		path = path..'/'..list[i2]
	end
	
	return path
end

function private.Path (to: Instance)
	return to:GetFullName()
end

interface.GetPath = private.Path;

return interface