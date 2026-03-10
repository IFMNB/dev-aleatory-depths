local main = require('./')

local private = {}
local class = {}; setmetatable(class,class);
local interface = {};

type SadSystemService = typeof(private.new({Name=''}))

function private.new <T,Y> (Service: T & main.DefaultServiceNeedle<Y>)
	return main.__SadAbstractService_protected.NewChild(Service :: T,class)
end

function private:while_active_do (F: ()->())
	local self = self :: SadSystemService;
	local system = self.OnActiveChangedEvent:Connect(function(State: boolean) 
		if State then
			xpcall(F,warn)
		end
	end)
	
	if self:IsActive() then
		xpcall(F,warn)
	end
	
	return system
end

class.__index = main.__SadAbstractService.class;
class.ClassName = main.Mapping.Class.SadSystemService;
class.Source = script;
class.DoWhileActive = private.while_active_do;


interface.class = class;
interface.new = private.new;

return main:expand({SadSystemService=interface})