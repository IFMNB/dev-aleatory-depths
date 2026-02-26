local main = require('./');

local Hx = main.Libs.Hexagon
local HxEvent = Hx.Classes.HxEvent()

local private = {};
local class = {}; setmetatable(class, class);
local interface = {};

type SadInstanceGroup = typeof(interface.new())
type function def (t: type, t1: type)
	assert(t:is('table') or t:is('unknown') or t:is('intersection'), 'Cannot handle type')
	return not t:is('unknown') and t or t1
end

function private.new <T> (Default: T?)
	local e0, c0 = HxEvent.new(class.ClassName);
	local e1, c1 = HxEvent.new(class.ClassName);
	
	return main.new({
		Elements = Default :: def<T, typeof(class.Elements)>;
		Reactions = {} :: typeof(class.Reactions);
		
		Add = function (self, a0) class.Add(self, a0) c0.Call(a0) end :: typeof(class.Add);
		Rem = function (self, a0) class.Rem(self, a0) c1.Call(a0) end :: typeof(class.Rem);
		
		OnElementAddedEvent = e0;
		OnElementRemovedEvent = e1;
		
	}, class)
end

function private:Add (Element: Instance)
	local self = self :: SadInstanceGroup;
	if table.find(self.Elements, Element) then return end
	table.insert(self.Elements, Element)
	
	if not self.Reactions[Element] then
		self.Reactions[Element] = Element.Destroying:Once(function() 
			local pos = table.find(self.Elements, Element)
			if pos then
				table.remove(self.Elements, pos)
			end
		end)
	end
end

function private:Remove (Element: Instance)
	local self = self :: SadInstanceGroup;
	local pos = table.find(self.Elements, Element)
	if pos then
		table.remove(self.Elements, pos)
	end
	
	if self.Reactions[Element] then
		self.Reactions[Element]:Disconnect()
		self.Reactions[Element] = nil
	end
end

class.__index = main._ISadGroup.class;
class.ClassName = main.Mapping.Class.SadInstanceGroup;
class.Source = script;
class.Reactions = {} :: {[Instance]: RBXScriptConnection};
class.Elements = class.__index.Elements :: {Instance};
class.Add = private.Add;
class.Rem = private.Remove;

interface.class = class;
interface.new = private.new;


return main:expand({SadInstanceGroup = interface})