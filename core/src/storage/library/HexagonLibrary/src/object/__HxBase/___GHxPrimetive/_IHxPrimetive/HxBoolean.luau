local main = require('./HxNumber')
local primetive = main._IHxPrimetive

local private = {}
local class = {}; class.__index=primetive.class;setmetatable(class,class)
local interface = {};


type HxString = typeof(interface.new())

--[[
	Creates new HxString object.

	@class HxString
	@return Instance (@P HxString)
]]
function private.new <t0> (value: boolean?)
	return main.new({Value=value::boolean}, class)
end


class.Value = false
class.ClassName=main.ClassNames.HxBoolean
class.Source = script
interface.class=class
interface.new = private.new

table.freeze(class)
table.freeze(private)
table.freeze(interface) 
return main:expand({
	HxBoolean = interface
})