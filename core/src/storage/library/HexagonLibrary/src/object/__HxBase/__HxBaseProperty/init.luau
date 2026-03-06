local main = require('./')

local private = {};
local class = {}; class.__index=main.__HxBase.class; setmetatable(class,class);
local interface = {}; interface.class = class;

class.ClassName=main.ClassNames.HxBaseProperty;
class.Source=script;

return main:expand({
	__HxBaseProperty=interface;
	HxConnection = require('./HxConnection').HxConnection;
	HxEvent = require('./HxEvent').HxEvent;
})