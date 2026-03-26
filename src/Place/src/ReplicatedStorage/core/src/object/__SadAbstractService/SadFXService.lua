local main = require('./')

local private = {}
local class = {}; setmetatable(class,class);
local interface = {};

function private.new <T,Y> (Service: T & main.DefaultServiceNeedle<Y>)
	return main.__SadAbstractService_protected.NewChild(Service :: T,class)
end


class.__index = main.__SadAbstractService.class;
class.ClassName = main.Mapping.Class.SadFXService;
class.Source = script;


interface.class = class;
interface.new = private.new;

return main:expand({SadFXService=interface})