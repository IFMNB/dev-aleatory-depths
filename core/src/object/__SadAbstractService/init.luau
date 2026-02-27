local main = require('./')


local Hx = main.Libs.Hexagon
local HxEvent = Hx.Classes.HxEvent()

local private = {};
local class = {}; setmetatable(class,class);
local protected = {};
local interface = {};

local http = game:GetService('HttpService')

export type DefaultServiceNeedle <Name=string> = {
	Name: Name,
	IsControllable: boolean
}
type SadAbstractService = typeof(class)


private.states = setmetatable({}::{[{}]: boolean}, {__mode='k'})
private.logstates = setmetatable({}::{[{}]: boolean}, {__mode='k'})
private.autostates = setmetatable({}::{[{}]: boolean}, {__mode='k'})


--[[
	Получает состояние сервиса, а точнее должен ли он работать в автоматическом режиме или нет.

	@class SadAbstractService
	@side all
	@return boolean
]]
function private:get_active_auto()
	local self = self::SadAbstractService;
	return self.IsControllable and not not private.autostates[self::any] or false
end

--[[
	Устанавливает состояние сервиса, а точнее должен ли он работать в автоматическом режиме или нет.

	@class SadAbstractService
	@side all
	@return ()
]]
function private:set_active_auto (value: boolean?)
	local self = self::SadAbstractService;
	if private.autostates[class] then
		class:PrintLog(string.format('Automode for %s is set to %s', self.Name, value and 'true' or 'false'))
	end
	
	if not self.IsControllable then
		return main.Mapping.Exception.CodeException:Warn(string.format('[%q] - Cannot set the automatic mode of operation on a service where it is not provided for by the IsControllable variable.', self.Name)) end
	private.autostates[self] = value or false
end

--[[
	Устанавливает состояние сервиса, а точнее должен ли он работать вообще или нет.

	@class SadAbstractService
	@side all
	@return boolean
]]
function private:get_active()
	return not not private.states[self::any]
end

--[[
	Устанавливает состояние сервиса, а точнее должен ли он работать вообще или нет.

	@class SadAbstractService
	@side all
	@return ()
]]
function private:set_active (value: boolean?)
	local self = self :: SadAbstractService;
	
	if private.states[class] then
		class:PrintLog(string.format('Active for %s is set to %s', self.Name, value and 'true' or 'false'))
	end
	
	private.states[self::any] = value or false
	private.c0.Call(self, value)
end

--[[
	Возвращает снапшот всех активных сервисов
	
	@class SadAbstractService
	@side all
	@return HxSnapshot
]]
function private:active ()
	return main.Libs.Hexagon.Classes.HxSnapshot().new(private.states)
end--[[
	Возвращает снапшот всех активных логгеров сервисов
	
	@class SadAbstractService
	@side all
	@return HxSnapshot
]]
function private:active_log ()
	return main.Libs.Hexagon.Classes.HxSnapshot().new(private.logstates)
end

--[[
	Устанавливает состояние сервиса, а точнее должен ли он обрабатывать логи или нет.
	
	@class SadAbstractService
	@side all
	@return ()
]]
function private:set_active_log (value: boolean?)
	
	if private.logstates[class] then
		class:PrintLog(string.format('Log for %s is set to %s', self.Name, value and 'true' or 'false'))
	end
	
	
	private.logstates[self::any] = value or false
end

--[[
	Получает состояние сервиса, а точнее должен ли он обрабатывать логи или нет.

	@class SadAbstractService
	@side all
	@return boolean
]]
function private:get_active_log ()
	return not not private.logstates[self::any]
end

--[[
	Пишет лог в консоль с указанным сообщением.
	
	Обертка над прозаичным string.format() с референсами на сервис и сообщением в передаче

	@class SadAbstractService
	@side all
	@return ()
]]
function private:log (...: any)
	local self = self::SadAbstractService;
	print(string.format('[Log] %q : %s', self.Name, tostring(...)))
end

--[[
	Защищенный конструктор создает сервис с соблюдением контракта самого абстрактоно сервиса.
	
	Оборачивает некоторые Set методы в обертку, чтобы ивенты могли срабатывать автоматически без пересоздания конструкторов.
	
	@class SadAbstractService
	@protected
	@side all
	@return SadServiceInstance

]]
function private.new_service <T,Y,Q> (Service: T & DefaultServiceNeedle<Y>, childClass: Q)
	local this = main.new(Service :: T, childClass);
	local nolint = this :: any
	
	nolint:SetActive(false);
	local e0, c0 = HxEvent.new();
	local e1, c1 = HxEvent.new();
	nolint.OnLogActiveChangedEvent, nolint.SetLogActive = e0, main.Abstract.Wrap(c0.Call,class.SetLogActive);
	nolint.OnActiveChangedEvent, nolint.SetActive = e1, main.Abstract.Wrap(c1.Call,class.SetActive);
	
	
	return this
end


class.__index=main.SadObject.class;
class.ClassName = main.Mapping.Class.SadAbstractService;
class.Source = script;

class.Name = class.ClassName;
class.IsControllable = false;

class.SetAuto = private.set_active_auto;
class.IsAuto = private.get_active_auto;

class.SetActive = private.set_active;
class.IsActive = private.get_active;

class.PrintLog = private.log;
class.SetLogActive = private.set_active_log;
class.IsLogActive = private.get_active_log;

private.e0, private.c0 = HxEvent.new();private.c0:Destroy();
class.OnActiveChangedEvent = private.e0;
class.OnLogActiveChangedEvent = private.e0;


protected.NewChild = private.new_service;

interface.class = class;
interface.GetActive = private.active;
interface.GetLogActive = private.active_log;

table.freeze(interface)
table.freeze(class)
table.freeze(private)
table.freeze(protected)

return main:expand({__SadAbstractService=interface, __SadAbstractService_protected=protected})