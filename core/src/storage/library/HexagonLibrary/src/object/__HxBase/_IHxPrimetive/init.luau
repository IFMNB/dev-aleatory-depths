local main = require('./__HxBaseProperty')

local private = {}
local class = {}; class.__index=main.__HxBase.class;setmetatable(class,class);
local interface = {};


class.ClassName=main.ClassNames.IHxPrimetive;
class.Source=script
class.Value = nil :: unknown
class.IsReplicatable = true :: true;

interface.class = class;

table.freeze(private)
table.freeze(class)
table.freeze(interface)
return main:expand({
	_IHxPrimetive=interface,
	HxEventCore = require('./__HxBaseProperty/HxActionEmitter/HxEventCore').HxEventCore,
	Hooks = require('./__HxBaseProperty/HxHooker').Hooks,
	Shade = require('./__HxBaseProperty/HxShade').Shade,
	MetalinkCreator = require('./__HxBaseProperty/__HxAbstractMetalink/HxMetalinkCreator').HxMetalinkCreator;
})