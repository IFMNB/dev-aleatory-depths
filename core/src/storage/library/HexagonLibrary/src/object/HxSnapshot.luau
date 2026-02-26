local main = require('./')

local private = {};
local class = {};setmetatable(class,class)
local interface = {};


type Snapshot = typeof(private.new({}::any))

function private.new <data> (object: data)
	local self = main.new({
		Snapshot = (class.IsA(object, 'HxObject') and main.new(object, class.GetClass(object)) or object) :: data;
		Data = DateTime.now().UnixTimestamp
	}, class)
	
	return self
end





class.__index=main.Objects.class;
class.Snapshot = nil :: unknown;
class.Data = 0 :: number;
class.Source=script;
class.ClassName = main.ClassNames.HxSnapshot;
class.IsReplicatable = true :: true;

interface.class=class;
interface.new = private.new;

table.freeze(class)
table.freeze(private)
table.freeze(interface)
return main:expand({Snapshot=interface})