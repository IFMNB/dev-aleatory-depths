local main = require('./')
local primetive = main.__HxAbstractPrimetive

local private = {}
local class = {}; class.__index=primetive.class;setmetatable(class,class)
local interface = {};

class.Value = '' :: string
class.ClassName=main.ClassNames.HxString

type HxString = typeof(interface.new())

function private.new <t0> (value: (string&t0)?)
	return primetive.new(value or class.Value, class)
end


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

class.Source = script
class.WriteGui = private.typeString
interface.class=class
interface.new = private.new

table.freeze(class)
table.freeze(private)
table.freeze(interface)
return main:expand({
	String = interface
})