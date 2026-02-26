local main = require('./')

local private = {};
local class = {}; setmetatable(class,class);
local interface = {};

class.__index=main.Libs.Hexagon.Classes.HxObject().class;
type SadClassNameSpace = keyof<typeof(main.ClassNames)>|keyof<typeof(main.Mapping.Class)>|string
type SadObject = typeof(class)

function private.new <data> (data: data)
	return main.new(data, class)
end

-- Returns true if an object's class matches or inherits from a given class. Overloaded
function private:IsA (ClassName: SadClassNameSpace)
	return class.__index.IsA(self, ClassName)
end
-- Returns true if an object's class constructor matches a given class. Overloaded
function private:IsClass (ClassName: SadClassNameSpace)
	return class.__index.IsClass(self, ClassName)
end
-- Returns the source of the object in string form.
function private:source_path ()
	local self = self :: SadObject;
	return main.Libs.RbxUtility.GetPath(self.Source);
end

class.IsA = private.IsA;
class.IsClass = private.IsClass;
class.Source = script;
class.ClassName = main.Mapping.Class.SadObject;
class.GetSourcePath = private.source_path;

interface.class = class;
interface.new = private.new;

table.freeze(class)
table.freeze(interface)
table.freeze(private)

return main:expand({SadObject=interface})