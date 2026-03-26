local private = {};
local interface = {};

-- Используйте GetFromIdentity
@deprecated
function private.FromPath (path: string?) : Instance?
	if path == '' or path == nil then
		return nil
	end
	
	
	local current = game
	for name in string.gmatch(path, "[^.]+") do
		if name ~= "game" then
			current = current:FindFirstChild(name)
			if not current then
				return nil
			end
		end
	end
	return current
end

@deprecated
function private.Path (to: Instance)
	return to and to.GetFullName and to:GetFullName() or ''
end

interface.GetPath = private.Path;
interface.FromPath = private.FromPath;

return interface