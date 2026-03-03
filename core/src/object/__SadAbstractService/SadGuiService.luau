local main = require('./')

local private = {}
local class = {}; setmetatable(class,class);
local interface = {};

function private.new <T,Y> (Service: T & main.DefaultServiceNeedle<Y>)
	return main.__SadAbstractService_protected.NewChild(Service :: T,class)
end


class.__index = main.__SadAbstractService.class;
class.ClassName = main.Mapping.Class.SadGuiService;
class.Source = script;
class.MyGui = nil :: ScreenGui?;

interface.class = class;
interface.new = private.new;

return main:expand({SadGuiService=interface})