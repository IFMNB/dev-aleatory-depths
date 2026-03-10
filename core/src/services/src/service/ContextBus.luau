local main = require('../')
local Mapping = main.Mapping

local HxEventCore = main.Core.Classes.HxEventCore()

local private = {}
local interface = {}

type DefaultFunction = (Context: string, ...any)->()

type HxEvent = typeof(private.e0);
type HxEventProperties = typeof(private.add_c)
type HxEventConnection = typeof(private.e0:Connect(function(...)  end))
type ContextControler = {Event: HxEvent, Properties: HxEventProperties, IsAlive: boolean}
type GameContextBusService = typeof(interface.Service)

private.registry = {} :: {[string]: ContextControler}

--[[
	Создает событие этого контекста.

	Возвращает контроллер с основными статусными показателями, в том числе и его
	статус жизни. Получить этот контроллер позже нельзя, все получатели будут
	брать HxEvent контроллера.

	@class GameContextBusService;
	@side all
	@exception CodeException
	@return ContextController
]]
function private:new (Context: string)
	local self = self :: GameContextBusService;
	if not self:IsActive() then
		self.OnActiveChangedEvent:Wait()
	end
	
	interface.Exceptions.CodeException:Assert(not private.registry[Context])
	local core = HxEventCore.new(warn :: DefaultFunction)
	private.registry[Context]={Event= core:AddEvent() ;Properties= core;IsAlive=true}
	
	if self:IsLogActive() then
		self:PrintLog(string.format('Context %q has been registried', Context))
	end
	
	private.add_c:DoCall(Context)
	return private.registry[Context]
end

--[[
	Уничтожает событие этого контекста.

	С данным уничтоженным контекстом больше нельзя взаимодействовать или получить,
	не переопределив контекст его пересозданием.
	
	@class GameContextBusService;
	@side all
	@exception CodeException
	@return ()
]]
function private:unregistry (Context: string)
	local self = self :: GameContextBusService;
	if not self:IsActive() then
		self.OnActiveChangedEvent:Wait()
	end
	
	interface.Exceptions.CodeException:Assert(private.registry[Context])
	private.registry[Context].IsAlive = false
	private.registry[Context].Properties:Destroy()
	table.freeze(private.registry[Context])
	private.registry[Context] = nil
	
	if self:IsLogActive() then
		self:PrintLog(string.format('Context %q has been destroyed', Context))
	end
	
	private.rem_c:DoCall(Context)
end

--[[
	Возвращает событие этого контекста.
	
	Если сервис неактивен или если ивент еще не был создан, то метод замораживает
	коррутину пока этот контекст не будет существовать. Если сработает текущий
	таймаут в сервисе, то есть данная коррутина оказалась заморожена достаточно
	давно, то сервис выведет ошибку.

	@class GameContextBusService
	@side all
	@exception RaceConditionException
	@return HxEvent
]]
function private:getregistry (Context: string)
	local self = self :: GameContextBusService;
	if not self:IsActive () then
		self.OnActiveChangedEvent:Wait()
	end
	
	if self:IsLogActive() then
		self:PrintLog(string.format('Catching context %q from registry', Context))
	end
	
	local ContextController = private.registry[Context]
	local Event
	if not ContextController then
		local clock = os.clock()
		local thread = coroutine.running()
		local con : HxEventConnection
		con = self.OnContextAddedEvent:Connect(function(ContextAdded: string) 
			if Context == ContextAdded then
				coroutine.resume(thread)
				con:Disconnect()
			else
				if clock - os.clock() > self.Timeout then
					con:Disconnect()
					interface.Exceptions.RaceConditionException:Throw()
				end
			end
		end)
		interface.Exceptions.RaceConditionException:Warn('The context event did not have time to be created by the time it was requested.')
		coroutine.yield()
		return private.registry[Context].Event
	else
		return ContextController.Event
	end
end


private.add_c = HxEventCore.new(warn :: DefaultFunction)
private.rem_c = HxEventCore.new(warn :: DefaultFunction)
private.e0 = private.add_c:AddEvent();
private.e1 = private.rem_c:AddEvent();

interface.Exceptions = table.freeze({
	CodeException = Mapping.Exception.CodeException;
	RaceConditionException = Mapping.Exception.RaceConditionException;
});
interface.Service = main.Core.Classes.SadCoreService().new({
	GetContext = private.getregistry;
	AddContext = private.new;
	RemoveContext = private.unregistry;
	
	OnContextAddedEvent = private.e0;
	OnContextRemovedEvent = private.e1;
	
	Name = 'GameContextBusService' :: 'GameContextBusService';
	IsControllable = false;
	Timeout = 5;
})

return interface