local main = require('./')

local private = {};
local class = {}; setmetatable(class, class);
local interface = {};

function private.new ()
	return main.new({
		Value={}
	},class)
end

class.__index=main._IHxList.class;
class.ClassName = main.ClassNames.HxList;
class.Source=script;
class.Value={}::{any};

interface.class = class;
interface.new = private.new;

return main:expand({HxList=interface})