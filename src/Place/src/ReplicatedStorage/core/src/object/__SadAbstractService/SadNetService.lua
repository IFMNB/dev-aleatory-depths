local main = require('./')

local private = {}
local class = {}; setmetatable(class,class);
local interface = {};

type SadNetService = typeof(private.new({Name=''}))

function private.new <T,Y> (Service: T & main.DefaultServiceNeedle<Y>)
	return main.__SadAbstractService_protected.NewChild(Service :: T,class)
end

private.autostates = setmetatable({}::{[{}]: boolean}, {__mode='k'})


--[[
	Получает состояние сервиса, а точнее должен ли он работать в автоматическом режиме или нет.

	@class SadAbstractService
	@side all
	@return boolean
]]
function private:get_active_auto()
	local self = self::SadNetService;
	return self.IsControllable and not not private.autostates[self::any] or false
end

--[[
	Устанавливает состояние сервиса, а точнее должен ли он работать в автоматическом режиме или нет.

	@class SadAbstractService
	@side all
	@return ()
]]
function private:set_active_auto (value: boolean?)
	local self = self::SadNetService;
	if private.autostates[class] then
		class:PrintLog(string.format('Automode for %s is set to %s', self.Name, value and 'true' or 'false'))
	end
	
	if private.autostates[self::any] == value then
		return
	end
	
	if not self.IsControllable then
		return main.Mapping.Exception.CodeException:Warn(string.format('[%q] - Cannot set the automatic mode of operation on a service where it is not provided for by the IsControllable variable.', self.Name)) end
	private.autostates[self] = value or false
end



class.__index = main.__SadAbstractService.class;
class.ClassName = main.Mapping.Class.SadNetService;
class.Source = script;
class.Behavior = nil :: unknown;
class.IsControllable = false;

class.SetAuto = private.set_active_auto;
class.IsAuto = private.get_active_auto;

interface.class = class;
interface.new = private.new;

return main:expand({SadNetService=interface})