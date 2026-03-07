local main = require('./');

local Hx = main.Libs.Hexagon
local HxEventCore = Hx.Classes.HxEventCore()

local private = {};
local class = {}; setmetatable(class, class);
local interface = {};

type SadInstanceGroup = typeof(interface.new())
type function def (t: type, t1: type)
	assert(t:is('table') or t:is('unknown') or t:is('intersection'), 'Cannot handle type')
	return not t:is('unknown') and t or t1
end

function private.new <T> (Default: T?)
	type DF = (Element: Instance)->()
	local Core1 = HxEventCore.new(warn::DF);
	local Core2 = HxEventCore.new(warn::DF);
	
	local Event1 = Core1:AddEvent();
	local Event2 = Core2:AddEvent();
	
	
	return main.new({
		Elements = Default :: def<T, typeof(class.Elements)>;
		Reactions = {} :: typeof(class.Reactions);
		
		Add = main.Abstract.Wrap(nil,class.Add,function(self,a0) Core1:DoCall(a0) end);
		Rem = main.Abstract.Wrap(nil,class.Rem,function(self,a0) Core2:DoCall(a0) end);
		
		OnElementAddedEvent = Event1;
		OnElementRemovedEvent = Event2;
		
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