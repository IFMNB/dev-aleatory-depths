local main = require('./');

local private = {};
local class = {}; setmetatable(class,class);
local interface = {};

function private.new ()
	return main.new({
		Value = setmetatable({} :: typeof(class.Value), {__mode='v'::'v'});
	}, class)
end

class.__index=main._IHxMap.class;
class.ClassName=main.ClassNames.HxWeakMap;
class.Source=script;
class.Value={}::{[string]:any};


interface.class = class;
interface.new = private.new;

return main:expand({HxWeakMap=interface})