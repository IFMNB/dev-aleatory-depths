local main = require('../')
local Mapping = main.Mapping
local private = {};
local interface = {};

type Context = typeof(Mapping.InputContextMap)
type Contexts = keyof<Context>
type ContextThis = index<Context,Contexts>
type NetIOContextService = typeof(interface.Service)
type IO = {IO: EnumItem, ST: EnumItem}

local NetPackageService = main.Core.Services.NetPackageService()
local GameContextBusService = main.Core.Services.GameContextBusService()
local UserInputService = game:GetService('UserInputService')
private.io = setmetatable({} :: {[ContextThis]: IO}, {__mode='k'})


--[[
	Переопределяет Ввод и Состояние для этого контекста.

	@class NetIOContextService
	@side client
	@exception CodeException
	@return ()
]]
function private:registry (Context: Contexts, IO: EnumItem?, ST: EnumItem?)
	local self = self :: NetIOContextService;
	if not self:IsActive () then
		self.OnActiveChangedEvent:Wait()
	end
	
	local context = interface.Exceptions.CodeException:Assert((Mapping.InputContextMap::any)[Context]) :: ContextThis
	local this : IO = private.io[context] or {} :: any
	
	if IO then
		this.IO = IO
	end
	
	if ST then
		this.ST = ST
	end
	
	private.io[context] = this
end

--[[
	Полностью удаляет все данные о данном контексте.

	@class NetIOContextService
	@side client
	@exception CodeException
	@return ()
]]
function private:unregistry (Context: Contexts)
	local self = self :: NetIOContextService;
	if not self:IsActive () then
		self.OnActiveChangedEvent:Wait()
	end
	
	local context = interface.Exceptions.CodeException:Assert((Mapping.InputContextMap::any)[Context]) :: ContextThis
	private.io[context] = nil
end

--[[
	Возвращает информацию о переопределениях контекста.

	@class NetIOContextService
	@side client
	@exception CodeException
	@return IO
]]
function private:get (Context: Contexts) : IO
	local self = self :: NetIOContextService;
	if not self:IsActive () then
		self.OnActiveChangedEvent:Wait()
	end
	
	
	local context = interface.Exceptions.CodeException:Assert((Mapping.InputContextMap::any)[Context]) :: ContextThis
	local this : IO = private.io[context] or {IO = context.DefaultIO; ST = context.DefaultState}
	return this
end

interface.Enums = table.freeze({
	Null = Mapping.Enum.Null;
});
interface.Exceptions = table.freeze({
	CodeException = Mapping.Exception.CodeException;
});
interface.Service = main.Core.Classes.SadNetService().new({
	AddContext = private.registry;
	RemoveContext = private.unregistry;
	GetContext = private.get;
	
	Name = 'NetIOContextService'::'NetIOContextService';
	Behavior = interface.Enums.Null :: index<typeof(interface.Enums), keyof<typeof(interface.Enums)>>;
	IsControllable = true;
})

local starter = function ()
	for i,v in Mapping.InputContextMap :: {[string]: ContextThis} do
		local Controller = GameContextBusService.Service:AddContext(v.Name);
		local Name = string.format('Activated IO Context for %q', v.Name)
		
		local function Reactor (input: InputObject, gameProcessedEvent: boolean)
			if not interface.Service:IsActive() then return end
			if not interface.Service:IsAuto() then return end
			if gameProcessedEvent then return end
			
			local IO = private.io[v] or {IO = v.DefaultIO; ST = v.DefaultState}
			if (input.KeyCode == IO.IO or input.UserInputType == IO.IO) and input.UserInputState == IO.ST then
				Controller.Properties.Call(interface.Service.Name)
				if interface.Service:IsLogActive() then
					interface.Service:PrintLog(Name)
				end
				NetPackageService.Service:SendServer(Mapping.Event.ContextNetwork, v.Name)
			end
		end
		
		UserInputService.InputBegan:Connect(Reactor)
		UserInputService.InputEnded:Connect(Reactor)
	end
end

if GameContextBusService.Service:IsActive() then
	starter()
else
	GameContextBusService.Service.OnActiveChangedEvent:Once(starter)
end



return interface