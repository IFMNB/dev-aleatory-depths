local main = require('../');
local Mapping = main.Mapping;

local private = {};
local interface = {};

local HxEvent = main.Core.Classes.HxEvent();
type GameContextBusService = typeof(interface.Service);
type HxEvent = typeof(private.e0); 
type HxEventProperties = typeof(private.c0);
type Controller = {
	Event: HxEvent,
	Control: HxEventProperties,
}

private.events = {}


--[[
	Возвращает созданное событие для контекста, а точнее весь его контроллер.

	@class GameContextBusService
	@side all
	@return Controller
]]
function private:ContextCreate (Context: string)
	local self = self :: GameContextBusService;
	
	local e0, c0 = HxEvent.new();
	local Controller  : Controller = {} :: any
	Controller.Event = e0
	Controller.Control = c0
	
	interface.Exceptions.CodeException:Assert(not private.events[Context])
	private.events[Context] = table.freeze(Controller);
	private.c0.Call(Context)
	
	return Controller
end


--[[
	Возвращает контекстное событие, а точнее сам ивент.
	
	@class GameContextBusService
	@side all
	@return HxEvent
]]
function private:ContextGet (Context: string)
	return interface.Exceptions.CodeException:Assert(private.events[Context].Event)
end


--[[
	Удаляет контекстное событие из шины событий.

	@class GameContextBusService
	@side all
	@return ()
]]
function private:ContextRemove (Context: string)
	local Controller = interface.Exceptions.CodeException:Assert(private.events[Context])
	Controller.Control:Destroy()
	private.events[Context] = nil
	private.c1.Call(Context)
end


private.e0, private.c0 = HxEvent.new();
private.e1, private.c1 = HxEvent.new();

interface.Enums = table.freeze({
	
});
interface.Exceptions = table.freeze({
	CodeException = Mapping.Exception.CodeException;
});
interface.Service = main.Core.Classes.SadGameService().new({
	GetContextEvent = private.ContextGet;
	AddContextEvent = private.ContextCreate;
	RemoveContextEvent = private.ContextRemove;	
	
	OnContextAdded = private.e0;
	OnContextRemoved = private.e1;
	
	Name = 'GameContextBusService'::'GameContextBusService';
	IsControllable = false;
});

return interface