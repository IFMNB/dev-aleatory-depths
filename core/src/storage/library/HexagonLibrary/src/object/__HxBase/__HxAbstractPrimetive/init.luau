local main = require('./')

local private = {}
local class = {}; class.__index=main.__HxBase.class;setmetatable(class,class);
local interface = {}; interface.class=class


function private.new <value,data,class> (value: value, class: class)
	return main.new({Value = value},class)
end

class.ClassName=main.ClassNames.HxAbstractPrimetive
class.Source=script
class.Value = nil :: unknown
class.IsReplicatable = true :: true;

interface.new = private.new

table.freeze(private)
table.freeze(class)
table.freeze(interface)
return main:expand({
	__HxAbstractPrimetive=interface,
	Events = require('./__HxBaseProperty/HxEvent').Events,
	Hooks = require('./__HxBaseProperty/HxHooker').Hooks,
	Shade = require('./__HxBaseProperty/HxShade').Shade,
	MetalinkCreator = require('./__HxBaseProperty/__HxAbstractMetalink/HxMetalinkCreator').HxMetalinkCreator
})