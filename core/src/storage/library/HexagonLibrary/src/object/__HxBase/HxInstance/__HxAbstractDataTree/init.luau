local main = require('./')

local class = {}; class.__index=main.HxInstance.class; setmetatable(class,class);
local interface = {}; interface.class=class

class.ClassName=main.ClassNames.HxAbstractDataTree;
class.Source=script;
class.IsReplicatable = true :: true; -- you should never manually replicate descendants of this class


return main:expand({
	__HxAbstractDataTree=interface,

})