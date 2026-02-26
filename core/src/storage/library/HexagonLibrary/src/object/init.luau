local main = require('./')
local MAP = main.ClassNames

local private = {}
local class = {};
local interface = {}; 

type HxObject = typeof(class)

-- Returns true if an object's class matches or inherits from a given class.
function private:IsA (ClassName: keyof<typeof(MAP)>|string) : boolean
	local visited = {}
	local function iterate(this: any)
		if visited[this] then return false else visited[this]=true end
		if type(this) ~= 'table' then return false end
		
		if this.ClassName == ClassName then return true end
		if not rawget(this,'__index') then
			local meta = getmetatable(this)
			if type(meta) == 'table' and meta.__index then
				return iterate(meta.__index)
			end
		else
			return iterate(this.__index)
		end
		
		return false
	end
	return iterate(self::any)
end
-- Returns true if an object's class-constructor matches a given class.
function private:ItAs (ClassName: keyof<typeof(MAP)>|string) : boolean
	return private.Class(self) == ClassName
end
-- Returns the ClassName of an object, gettering from the metatable.
function private:Class () : string
	return getmetatable(self::any).__index
end

-- Returns true if object data is equal to another object's data.
function private:Equal (with: any)
	return private.Match(self,with) == private.Match(with,self) and class.IsSimilar(self,with)
end
-- Returns true if object data is similar to another object's data, but not necessarily full equality from target object.
function private:Match  (with: any)
	local self : {[any]:any} = assert(type(self::any)=='table' and self :: any, 'cannot check equality')
	if typeof(with)~='table' then return false end

	for i,v in self do
		if with[i] ~= v then
			return false
		end
	end

	return true
end

-- Returns true if both objects have the same class as a constructor.
function private:From (this: any)
	return class.GetClass(self::HxObject) == class.GetClass(this::HxObject?)
end

function private.new <data> (data: data)
	return main.new(data, class)
end

class.GetClass = private.Class;
class.IsClass = private.ItAs;
class.IsA = private.IsA;
class.IsEquals = private.Equal;
class.IsSimilar = private.From;
class.IsMatch = private.Match;
class.ClassName = MAP.HxObject;
class.Source=script;
class.IsReplicatable = false :: false;

interface.class=class
interface.new = private.new


table.freeze(class)
table.freeze(interface)
table.freeze(private)
return main:expand({Objects=interface})