local main = require('../')
local Mapping = main.Mapping

-- TODO
-- Добавить сюда логику синхронизации с сервером


local private = {}
local interface = {}

local HxEvent = main.Core.Classes.HxEvent()
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
	private.c0.Call(Context,State,Key)
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
	private.c1.Call(Context,State,Input)
end

private.e0, private.c0 = HxEvent.new();
private.e1, private.c1 = HxEvent.new();

interface.Enums = table.freeze({
	Null = Mapping.Enum.Null;
});
interface.Exceptions = table.freeze({
	GameException = main.Mapping.Exception.GameException;
});
interface.Service = main.Core.Classes.SadNetService().new({
	SendContextKeyChange = private.change_key;
	SendContextInputChange = private.change_input;	
	
	OnContextKeyChange = private.c0;
	OnContextInputChange = private.c1;
	
	Name = 'GameIOMappingService'::'GameIOMappingService';
	Behavior = interface.Enums.Null :: index<typeof(interface.Enums), keyof<typeof(interface.Enums)>>;
	IsControllable = false;
});

return interface