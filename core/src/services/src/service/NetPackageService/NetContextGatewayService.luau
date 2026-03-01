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


function private:new (Context: string)
	local self = self :: NetContextGatewayService;
	if not self:IsActive () then
		self.OnActiveChangedEvent:Wait()
	end
	
	
	local Controller : Controller = {} :: any
	Controller.Event, Controller.Properties = HxEvent.new()
	private.controllers[Context] = Controller
	private.events[Controller.Event]=Controller
	
	if self:IsLogActive() then
		self:PrintLog(`New context {Context}`)
	end
	
	return Controller.Event
end

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

function private:remove (Context: string)
	local self = self :: NetContextGatewayService;
	if not self:IsActive () then
		self.OnActiveChangedEvent:Wait()
	end
	
	private.controllers[Context] = nil
	
	if self:IsLogActive() then
		self:PrintLog(`Removed context {Context}`)
	end
end

function private:forplayer (Player: Player, Context: string, F: (...any)->(), Once: boolean?)
	local self = self :: NetContextGatewayService;
	if not self:IsActive () then
		self.OnActiveChangedEvent:Wait()
	end
	
	return NetPackageService.Service:ForPlayer(Player, self:GetContext(Context), F, Once)
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
	ForPlayer = private.forplayer;
	
	Name = 'NetContextGatewayService'::'NetContextGatewayService';
	Behavior = interface.Enums.Null;
	IsControllable = false;
})

NetPackageService.Service:ForEvent(Mapping.Event.ContextNetwork):Connect(function(firstline: Player?|string, nextline: string|any, ...: any)
	if not interface.Service:IsActive() then return end
	if not interface.Service:IsAuto() then return end
	
	local Controller
	if typeof(firstline) == 'string' then
		Controller = private.controllers[firstline]
		if Controller then
			Controller.Properties.Call(nextline, ...)
			
			if interface.Service:IsLogActive() then
				interface.Service:PrintLog(string.format('Context %q called with args %q', firstline, table.concat({...},', ')))
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
		end
	end
end)


return interface