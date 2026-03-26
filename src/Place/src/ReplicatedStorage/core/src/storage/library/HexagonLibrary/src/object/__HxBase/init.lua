local main = require('./')

local private = {}
local class = {}; class.__index=main.Objects.class; setmetatable(class,class);
local interface = {}; interface.class=class


class.Source=script
class.ClassName=main.ClassNames.HxBase

return main:expand({
	__HxBase=interface,
	I_Object = require('../interface/src_object')
})