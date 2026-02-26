local main = require('./')

local private = {}
local class = {}; setmetatable(class,class);
local interface = {};

function private.new <T,Y> (Service: T & main.DefaultServiceNeedle<Y>)
	local this = main.new(Service :: T, class);
	(this::any):SetActive(false);
	return this
end


class.__index = main.__SadAbstractService.class;
class.ClassName = main.Mapping.Class.SadGameService;
class.Source = script;


interface.class = class;
interface.new = private.new;

return main:expand({SadGameService=interface})