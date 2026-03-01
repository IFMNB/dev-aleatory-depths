local main = require('../')
local Mapping = main.Mapping

local HxEvent = main.Core.Classes.HxEvent()

local private = {}
local interface = {}

type HxEvent = typeof(private.e0);
type HxEventProperties = typeof(private.c0)
type HxEventConnection = typeof(private.e0:Connect(function(...)  end))
type ContextControler = {Event: HxEvent, Properties: HxEventProperties, IsAlive: boolean}
type GameContextBusService = typeof(interface.Service)

private.registry = {} :: {[string]: ContextControler}

--[[
	Создает событие этого контекста.

	Возвращает контроллер с основными статусными показателями, в том числе и
	его статус жизни. Получить этот контроллер нельзя, все получатели будут
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
	local e0,c0 = HxEvent.new()
	private.registry[Context]={Event=e0;Properties=c0;IsAlive=true}
	
	if self:IsLogActive() then
		self:PrintLog(string.format('Context %q has been registried', Context))
	end
	
	private.c0.Call(Context)
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
	
	private.c0.Call(Context)
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

private.e0, private.c0 = HxEvent.new();
private.e1, private.c1 = HxEvent.new();

interface.Enums = table.freeze({
	Deffered = Mapping.Enum.ActionSignalBehavior.Deffered;
	Immediate = Mapping.Enum.ActionSignalBehavior.Immediate;
});
interface.Exceptions = table.freeze({
	CodeException = Mapping.Exception.CodeException;
	RaceConditionException = Mapping.Exception.RaceConditionException;
});
interface.Service = main.Core.Classes.SadGameService().new({
	GetContext = private.getregistry;
	AddContext = private.new;
	RemoveContext = private.unregistry;
	
	OnContextAddedEvent = private.e0;
	OnContextRemovedEvent = private.e1;
	
	Name = 'GameContextBusService' :: 'GameContextBusService';
	Behavior = interface.Exceptions.CodeException;
	IsControllable = false;
	Timeout = 5;
})

return interface