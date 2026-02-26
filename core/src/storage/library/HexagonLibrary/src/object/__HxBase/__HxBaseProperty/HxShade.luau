local main = require('./')

local private = {}
local class = {}; class.__index=main.__HxBaseProperty.class; setmetatable(class,class)
local interface = {}; interface.class=class

private.mt={__index=class}
private.mt2={__mode='k'::'k'}

-- Special class for storing private instances data
function private.new ()
	return main.new({Stored=setmetatable({},private.mt2)},class)
end

-- Return private table for this instance. Be sure this instance is _GC available instance. If not, stored data will not be deleted automatically.
function private:get (Data: any) : any | {[any]:any}
	local this = (self::any).Stored[Data]
	if this ~= nil then
		return this
	else
		local val = {}
		(self::any).Stored[Data] = val
		return val
	end
end
-- Settin up your custom value to this instance. Be sure this instance is _GC available instance. If not, stored data will not be deleted automatically.
function private:Set (Data: any, To: any)
	(self::any).Stored[Data]=To
end

class.ClassName=main.ClassNames.HxShade
class.Set=private.Set
class.Get=private.get
class.Source=script
interface.new = private.new

table.freeze(class)
table.freeze(private)
table.freeze(interface)
return main:expand({Shade=interface})