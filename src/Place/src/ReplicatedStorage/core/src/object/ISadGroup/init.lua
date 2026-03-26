local main = require('./');

local Hx = main.Libs.Hexagon
local HxEvent = Hx.Classes.HxEvent()

local private = {};
local class = {}; setmetatable(class, class);
local interface = {};

type ISadGroup = typeof(class)

-- @From InterfaceClass
function private:find (element: any)
	local self = self :: ISadGroup;
	return not not table.find(self.Elements, element)
end

class.__index = main.SadObject.class;
class.ClassName = main.Mapping.Class.ISadGroup
class.Source = script;



class.Add = main.Abstract.SelfOverride;
class.Rem = main.Abstract.SelfOverride;
class.AreElementInGroup = private.find;
class.Elements = {} :: {any};
class.OnElementAddedEvent = HxEvent.instance;
class.OnElementRemovedEvent = HxEvent.instance;


interface.class = class;

return main:expand({_ISadGroup = interface})