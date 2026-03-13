local main = require('../___GHxPrimetive')

local private = {};
local class = {}; class.__index=main.__HxBase.class; setmetatable(class,class);
local interface = {}; interface.class = class;

class.ClassName=main.ClassNames.IHxProperty;
class.Source=script;

return main:expand({
	_IHxProperty=interface;
})