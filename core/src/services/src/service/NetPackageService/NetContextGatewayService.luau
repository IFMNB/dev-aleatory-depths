local main = require('../..')
local Mapping = main.Mapping

local NetPackageService = require('./')
local HxEventCore = main.Core.Classes.HxEventCore()

local private = {}
local interface = {}

type DefaultFunction = (Context: string, ...any) -> ()
type HxEventCore = typeof(HxEventCore.new(warn::DefaultFunction))
type HxEvent = typeof(HxEventCore.new(warn::DefaultFunction):AddEvent())

type Controller = {Event: HxEvent, Properties: HxEventCore}

type NetContextGatewayService = typeof(interface.Service)
private.controllers = setmetatable({} :: {[string]: Controller?},{__mode='v'})
private.events = setmetatable({}::{[HxEvent]:Controller}, {__mode='k'})

--[[
	Регистрирует подписку на данный контекст, или возвращает уже созданную.
	
	Подписка сама по себе означает то, что машина может принимать события по этому контексту.
	Это стоит воспринимать как канал передачи информации, в котором может перекидываться что
	угодно.

	@class NetContextGatewayService
	@side all
	@return HxEvent
]]
function private:new (Context: string)
	local self = self :: NetContextGatewayService;
	if not self:IsActive () then
		self.OnActiveChangedEvent:Wait()
	end
	
	local Controller : Controller = (private.controllers[Context] or {}) :: any
	if Controller :: Controller then
		return Controller.Event
	end
	
	local Core = HxEventCore.new(warn::DefaultFunction);
	local Event = Core:AddEvent();
	
	Controller.Properties = Core;
	Controller.Event = Event
	
	private.controllers[Context] = Controller
	private.events[Controller.Event]=Controller
	
	if self:IsLogActive() then
		self:PrintLog(`New context {Context}`)
	end
	
	private.add:DoCall(Context)
	
	return Controller.Event
end

--[[
	Возвращает существующую подписку на этот контекст.
	
	@class NetContextGatewayService
	@side all
	@exception RaceConditionException
	@return HxEvent
]]
function private:get (Context: string)
	local self = self :: NetContextGatewayService;
	if not self:IsActive () then
		self.OnActiveChangedEvent:Wait()
	end
	
	local Controller = private.controllers[Context]
	local this = Controller and Controller.Event or interface.Exceptions.RaceConditionException:Throw()
	
	if self:IsLogActive() then
		self:PrintLog(`Got context {Context}`)
	end
	
	return this
end

--[[
	Удаляет контекст из ворот реагирования.
	
	@class NetContextGatewayService
	@side all
	@return ()
]]
function private:remove (Context: string)
	local self = self :: NetContextGatewayService;
	if not self:IsActive () then
		self.OnActiveChangedEvent:Wait()
	end
	
	local Controller = private.controllers[Context]
	if Controller then
		Controller.Properties:Destroy()
	end
	
	private.controllers[Context] = nil
	
	if self:IsLogActive() then
		self:PrintLog(`Removed context {Context}`)
	end
	
	private.rem:DoCall(Context)
end


--[[
	Оберточная форма для получения контекста.
	
	Метод полностью работает на NetPackageService:ForPlayer(). В этом сервисе представляет немного безопасную версию
	контроля доступа.
	
	@class NetContextGatewayService
	@side all
	@return HxEventConnection
]]
function private:forplayer (Player: Player, Context: string, F: DefaultFunction, Once: boolean?)
	local self = self :: NetContextGatewayService;
	if not self:IsActive () then
		self.OnActiveChangedEvent:Wait()
	end
	
	return NetPackageService.Service:ForPlayer(Player, self:GetContext(Context), F, Once)
end


--[[
	Отправляет активацию контекста и его полезную загрузку другим локальным машинам.
	
	С клиента на сервер, а с сервера всем клиентам.
	
	@class NetContextGatewayService
	@side all
	@return ()
]]
function private:sendContext (Context: string,  ... : any)
	local self = self :: NetContextGatewayService;
	if not self:IsActive () then return end
	
	local state = game["Run Service"]:IsClient()
	
	if not state then
		NetPackageService.Service:SendAllClients(Mapping.Event.ContextNetwork, Context, ...)
	else
		NetPackageService.Service:SendServer(Mapping.Event.ContextNetwork, Context, ...)
	end
	
	if self:IsLogActive() then
		self:PrintLog(`Sending context {Context}`)
	end
end

private.add = HxEventCore.new(warn::DefaultFunction);private.e_add=private.add:AddEvent();
private.rem = HxEventCore.new(warn::DefaultFunction);private.e_rem=private.rem:AddEvent();

interface.Enums = table.freeze({
	Null = main.Mapping.Enum.Null
})
interface.Exceptions = table.freeze({
	SafetyException = Mapping.Exception.SafetyException;
	CodeException = Mapping.Exception.CodeException;
	RaceConditionException = Mapping.Exception.RaceConditionException;
})
interface.Service = main.Core.Classes.SadNetService().new({
	GetContext = private.get;
	RemoveContext = private.remove;
	AddContext = private.new;
	ContextForPlayer = private.forplayer;
	SendContext = private.sendContext;
	
	OnContextAddedEvent = private.e_add;
	OnContextRemovedEvent = private.e_rem;
	
	Name = 'NetContextGatewayService'::'NetContextGatewayService';
	Behavior = interface.Enums.Null;
	IsControllable = false;
})

NetPackageService.Service:ForEvent(Mapping.Event.ContextNetwork):Connect(function(arg1: Player | buffer | {  }, arg2: (any | buffer | {  })?, ...) 
	if not interface.Service:IsActive() then return end
	
	local Controller
	if typeof(arg1) == 'string' then
		Controller = private.controllers[arg1]
		if Controller then
			Controller.Properties:DoCall(arg2, ...)
			
			if interface.Service:IsLogActive() then
				interface.Service:PrintLog(string.format('Context %q called with args %q', arg1, table.concat({...},', ')))
			end	
		else
			if interface.Service:IsLogActive() then
				interface.Service:PrintLog(string.format('Context %q called, but controller not found', arg1))
			end
		end
	else
		local nextline : string = interface.Exceptions.SafetyException:Assert(type(arg2) == 'string' and arg2)
		Controller = private.controllers[nextline]
		if Controller then
			Controller.Properties:DoCall(nextline, ...)
			
			if interface.Service:IsLogActive() then
				interface.Service:PrintLog(string.format('Context %q called with args %q by player %q', nextline, table.concat({...},', '), (arg1::Player).DisplayName))
			end
		else
			if interface.Service:IsLogActive() then
				interface.Service:PrintLog(string.format('Context %q called by player %q, but controller not found', nextline, (arg1::Player).DisplayName))
			end
		end
	end
end)



return interface