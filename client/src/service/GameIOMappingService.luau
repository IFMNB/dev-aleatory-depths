local main = require('../')
local Mapping = main.Mapping

-- TODO
-- Добавить сюда логику синхронизации с сервером


local private = {}
local interface = {}

local HxEventCore = main.Core.Classes.HxEventCore()
local NetPackageService = main.Core.Services.NetPackageService()
type GameIOMappingService = typeof(interface.Service)

--[[
	Отправляет изменения для контекста ключей на сервер.
	
	@class GameIOMappingService
	@side client
	@return ()
]]
function private:change_key (Context: string,  State: Enum.UserInputState, Key: Enum.KeyCode)
	local self = self :: GameIOMappingService;
	if not self:IsActive() then return end
	if self:IsLogActive() then
		self:PrintLog(string.format('Changed context %q to key %s', Context, Key.Name))
	end
	
	NetPackageService.Service:SendServer(Mapping.Event.ContextKeyNetwork, Context, Key, State)
	private.Core1:DoCall(Context,State,Key)
end

--[[
	Отправляет изменения для контекста вводов на сервер.
	
	@class GameIOMappingService
	@side client
	@return ()
]]
function private:change_input (Context: string,  State: Enum.UserInputState, Input: Enum.UserInputType)
	local self = self :: GameIOMappingService;
	if not self:IsActive() then return end
	
	if self:IsLogActive() then
		self:PrintLog(string.format('Changed context %q to input %s', Context, Input.Name))
	end
	
	NetPackageService.Service:SendServer(Mapping.Event.ContextInputNetwork, Context, Input, State)
	private.Core2:DoCall(Context,State,Input)
end

type DFC1 = (Context: string, State: Enum.UserInputState, Key: Enum.KeyCode)->()
type DFC2 = (Context: string, State: Enum.UserInputState, Input: Enum.UserInputType)->()

private.Core1 = HxEventCore.new(warn::DFC1);
private.Core2 = HxEventCore.new(warn::DFC2);
private.Event1 = private.Core1:AddEvent();
private.Event2 = private.Core2:AddEvent();


interface.Enums = table.freeze({
	Null = Mapping.Enum.Null;
});
interface.Exceptions = table.freeze({
	GameException = main.Mapping.Exception.GameException;
});
interface.Service = main.Core.Classes.SadNetService().new({
	SendContextKeyChange = private.change_key;
	SendContextInputChange = private.change_input;	
	
	OnContextKeyChange = private.Event1;
	OnContextInputChange = private.Event2;
	
	Name = 'GameIOMappingService'::'GameIOMappingService';
	Behavior = interface.Enums.Null :: index<typeof(interface.Enums), keyof<typeof(interface.Enums)>>;
	IsControllable = false;
});

return interface