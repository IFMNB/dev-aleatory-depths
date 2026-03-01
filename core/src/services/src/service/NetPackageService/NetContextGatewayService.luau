local main = require('../..')
local Mapping = main.Mapping

local NetPackageService = require('./')
local HxEvent = main.Core.Classes.HxEvent()

local private = {}
local interface = {}

type Controller = {Event: HxEvent, Properties: HxEventProperties}
type HxEvent = typeof(private.e0); type HxEventProperties = typeof(private.c0); type HxEventConnection = typeof(private.e0:Connect(function(...)  end))
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
	
	local Controller : Controller = private.controllers[Context] :: any
	if Controller then
		return Controller.Event
	end
	
	Controller = {} :: any
	Controller.Event, Controller.Properties = HxEvent.new()
	private.controllers[Context] = Controller
	private.events[Controller.Event]=Controller
	
	if self:IsLogActive() then
		self:PrintLog(`New context {Context}`)
	end
	
	private.c0.Call(Context)
	
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
	
	private.c1.Call(Context)
end


--[[
	Оберточная форма для получения контекста.
	
	Метод полностью работает на NetPackageService:ForPlayer(). В этом сервисе представляет немного безопасную версию
	контроля доступа.
	
	@class NetContextGatewayService
	@side all
	@return HxEventConnection
]]
function private:forplayer (Player: Player, Context: string, F: (...any)->(), Once: boolean?)
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

private.e0, private.c0 = HxEvent.new();
private.e1, private.c1 = HxEvent.new();


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
	
	Name = 'NetContextGatewayService'::'NetContextGatewayService';
	Behavior = interface.Enums.Null;
	IsControllable = false;
})

NetPackageService.Service:ForEvent(Mapping.Event.ContextNetwork):Connect(function(firstline: Player?|string, nextline: string|any, ...: any)
	if not interface.Service:IsActive() then return end
	
	local Controller
	if typeof(firstline) == 'string' then
		Controller = private.controllers[firstline]
		if Controller then
			Controller.Properties.Call(nextline, ...)
			
			if interface.Service:IsLogActive() then
				interface.Service:PrintLog(string.format('Context %q called with args %q', firstline, table.concat({...},', ')))
			end	
		else
			if interface.Service:IsLogActive() then
				interface.Service:PrintLog(string.format('Context %q called, but controller not found', firstline))
			end
		end
	else
		local nextline : string = interface.Exceptions.SafetyException:Assert(type(nextline) == 'string' and nextline)
		Controller = private.controllers[nextline]
		if Controller then
			Controller.Properties.Call(nextline, ...)
			
			if interface.Service:IsLogActive() then
				interface.Service:PrintLog(string.format('Context %q called with args %q by player %q', nextline, table.concat({...},', '), (firstline::Player).DisplayName))
			end
		else
			if interface.Service:IsLogActive() then
				interface.Service:PrintLog(string.format('Context %q called by player %q, but controller not found', nextline, (firstline::Player).DisplayName))
			end
		end
	end
end)



return interface