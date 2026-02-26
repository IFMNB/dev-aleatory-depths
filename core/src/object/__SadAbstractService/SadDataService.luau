local main = require('./')

local private = {}
local class = {}; setmetatable(class,class);
local interface = {};

function private.new <T> (Service: T)
	return main.new(Service, class)
end


class.__index = main.__SadAbstractService.class;
class.ClassName = main.Mapping.Class.SadDataService;
class.Source = script;


interface.class = class;
interface.new = private.new;

return main:expand({SadDataService=interface})