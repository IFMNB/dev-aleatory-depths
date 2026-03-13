local main = require('./HxBoolean')
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
function private.new <t0> (value: string?)
	return main.new({Value=value::string}, class)
end

--[[
	Write text in gui letter by letter. 

	@class HxString
	@return ()
]]
function private:typeString (gui: TextBox|TextLabel|TextButton, time: number?)
	local this = self:: HxString
	local txt = if typeof(this.Value) == 'string' then this.Value else error('')
	
	txt = txt:gsub("<br%s*/>", "\n")
	txt = txt:gsub("<[^<>]->", "")
	
	gui.MaxVisibleGraphemes=0
	gui.Text=txt
	
	for i=1, #txt do
		gui.MaxVisibleGraphemes+=1
		if time then task.wait(time) end
	end
end

class.Value = ''
class.ClassName=main.ClassNames.HxString
class.Source = script
class.WriteGui = private.typeString
interface.class=class
interface.new = private.new

table.freeze(class)
table.freeze(private)
table.freeze(interface) 
return main:expand({
	HxString = interface
})