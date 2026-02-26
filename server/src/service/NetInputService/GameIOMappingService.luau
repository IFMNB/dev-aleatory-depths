--!native
--!optimize 2

local main = require('../..')
local Mapping = main.Mapping

-- TODO
-- Однажды в далеком прекрасном будущем этот сервис должен быть упрощен,
-- или хотя бы немного оптимизирован


local private = {}
local interface = {}

type GameIOMappingService = typeof(interface.Service)
type HxEvent = typeof(private.e4);
type HxEventProperties = typeof(private.c4)
type HxEventConnection <Fua=any> = typeof(private.e4:Connect(nil::Fua))

type Controller = {
	Event: HxEvent,
	Control: HxEventProperties,
	NIS_connection: HxEventConnection,
	EnumItem: Enum.KeyCode | Enum.UserInputType,
	State: States,
	DefaultEnumItem: Enum.KeyCode | Enum.UserInputType
}
type ContextMap = {[string]: Controller}
type States = typeof(private.Map_End) | typeof(private.Map_Begin)

local HxEvent = main.Core.Classes.HxEvent()
local NetPackageService = main.Core.Services.NetPackageService()
local NetInputService = require('./')

private.default_key_begin = {} :: ContextMap
private.default_input_begin = {} :: ContextMap
private.default_key_end = {} :: ContextMap
private.default_input_end = {} :: ContextMap

private.players_key_begin = {} :: {[Player]: ContextMap}
private.players_input_begin = {} :: {[Player]: ContextMap}
private.players_key_end = {} :: {[Player]: ContextMap}
private.players_input_end = {} :: {[Player]: ContextMap}

private.players_auto = {} :: {[Player]: { -- собственно сам маппер каждого игрока для каждого контекстного действия
	Destroy: RBXScriptConnection,
	KeyEvent: HxEventConnection, -- вызывает контексты для клавиатуры
	InputEvent: HxEventConnection, -- вызывает контексты для вводов
	ChangesToKey: HxEventConnection, -- обновляет ключи игрока (аналогии)
	ChangesToInput: HxEventConnection, -- обновляет ввод игрока (аналогии)
}}

private.Map_End = Enum.UserInputState.End
private.Map_Begin = Enum.UserInputState.Begin

function private.STATE_get (State: Enum.UserInputState) : States
	return State or interface.Exceptions.CodeException:Throw()
end

function private.KEY_get (State: States)
	return State == private.Map_End and private.default_key_end
		or State == private.Map_Begin and private.default_key_begin
		or interface.Exceptions.CodeException:Throw()
end

function private.INPUT_get (State: States)
	return State == private.Map_End and private.default_input_end
		or State == private.Map_Begin and private.default_input_begin
		or interface.Exceptions.CodeException:Throw()
end

function private.PLAYER_KEY_get (Player: Player, State: States)
	return State == private.Map_End and private.players_key_end[Player]
		or State == private.Map_Begin and private.players_key_begin[Player]
		or interface.Exceptions.CodeException:Throw()
end

function private.PLAYER_INPUT_get (Player: Player, State: States)
	return State == private.Map_End and private.players_input_end[Player]
		or State == private.Map_Begin and private.players_input_begin[Player]
		or interface.Exceptions.CodeException:Throw()
end

--[[
	Добавляет игрока в автоматический учет контекстных изменений.
	
	@class GameIOMappingService
	@side server
	@return ()
]]
function private:PLAYER_add (Player: Player)
	local self = self :: GameIOMappingService;
	
	interface.Exceptions.CodeException:Assert(not private.players_key_begin[Player])
	interface.Exceptions.CodeException:Assert(not private.players_input_begin[Player])
	interface.Exceptions.CodeException:Assert(not private.players_key_end[Player])
	interface.Exceptions.CodeException:Assert(not private.players_input_end[Player])
	
	if self:IsLogActive() then
		self:PrintLog(string.format('Added player %s', Player.DisplayName))
	end
	
	local Destroy = Player.Destroying:Once(function()
		private:PLAYER_remove(Player)
	end)
	
	private.players_auto[Player] = {
		Destroy = Destroy,
		KeyEvent = NetInputService.Service:GetPlayerKeyChangeEvent(Player):Connect(function(Key: Enum.KeyCode, State: Enum.UserInputState)
			local Transmitted : States = private.STATE_get(State)
			for i,v in private.players_key_begin[Player] do
				if v.EnumItem == Key and v.State == Transmitted then
					v.Control.Call()
					
					if self:IsLogActive() then
						self:PrintLog(string.format('Player %s activated context %s in begin keys', Player.DisplayName, i))
					end
				end
			end
			
			for i,v in private.players_key_end[Player] do
				if v.EnumItem == Key and v.State == Transmitted then
					v.Control.Call()
					
					if self:IsLogActive() then
						self:PrintLog(string.format('Player %s activated context %s in end keys', Player.DisplayName, i))
					end
				end
			end
		end),
		InputEvent = NetInputService.Service:GetPlayerInputChangeEvent(Player):Connect(function(Key: Enum.KeyCode, State: Enum.UserInputState)
			local Transmitted : States = private.STATE_get(State)
			for i,v in private.players_input_begin[Player] do
				if v.EnumItem == Key and v.State == Transmitted then
					v.Control.Call()
					
					if self:IsLogActive() then
						self:PrintLog(string.format('Player %s activated context %s in begin inputs', Player.DisplayName, i))
					end
				end
			end
			
			for i,v in private.players_input_end[Player] do
				if v.EnumItem == Key and v.State == Transmitted then
					v.Control.Call()
					
					if self:IsLogActive() then
						self:PrintLog(string.format('Player %s activated context %s in end inputs', Player.DisplayName, i))
					end
				end
			end
		end),
		ChangesToKey = NetPackageService.Service:ForPlayer(Player, Mapping.Event.ContextKeyNetwork, function(Context: string, IO: Enum.KeyCode, State: Enum.UserInputState) 
			interface.Exceptions.CodeException:Assert(IO)
			interface.Exceptions.CodeException:Assert(State)
			interface.Exceptions.CodeException:Assert(self.Behavior == interface.Enums.AllowChanges)
			
			local KEY = private.PLAYER_KEY_get(Player, State)
			local Controller : Controller = interface.Exceptions.RaceConditionException:Assert(KEY[Context])
			Controller.EnumItem = IO
			
			if self:IsLogActive() then
				self:PrintLog(string.format('Changed key for %s to %s', Context, tostring(IO)))
			end
			
			private.c5.Call(Player, Context, State)
		end),
		ChangesToInput = NetPackageService.Service:ForPlayer(Player, Mapping.Event.ContextInputNetwork, function(Context: string, IO: Enum.UserInputType, State: Enum.UserInputState) 
			interface.Exceptions.CodeException:Assert(IO)
			interface.Exceptions.CodeException:Assert(State)
			interface.Exceptions.CodeException:Assert(self.Behavior == interface.Enums.AllowChanges)
			
			
			local KEY = private.PLAYER_INPUT_get(Player, State)
			local Controller : Controller = interface.Exceptions.RaceConditionException:Assert(KEY[Context])
			Controller.EnumItem = IO
			
			if self:IsLogActive() then
				self:PrintLog(string.format('Changed input for %s to %s', Context, tostring(IO)))
			end
			
			private.c7.Call(Player, Context, State)
		end)
	}
	
	private.players_key_begin[Player] = {}
	private.players_input_begin[Player] = {}
	private.players_key_end[Player] = {}
	private.players_input_end[Player] = {}
end

--[[
	Удаляет из автоматического учета изменения контекстов у игрока
	
	@class GameIOMappingService
	@side server
	@return ()
]]
function private:PLAYER_remove (Player: Player)
	interface.Exceptions.CodeException:Assert(private.players_key_begin[Player])
	interface.Exceptions.CodeException:Assert(private.players_input_begin[Player])
	interface.Exceptions.CodeException:Assert(private.players_key_end[Player])
	interface.Exceptions.CodeException:Assert(private.players_input_end[Player])
	
	if interface.Service:IsLogActive() then
		interface.Service:PrintLog(string.format('Removed player %s', Player.DisplayName))
	end
	
	if private.players_auto[Player] then
		if private.players_auto[Player].Destroy.Connected then
			private.players_auto[Player].Destroy:Disconnect()
		end
		
		if private.players_auto[Player].KeyEvent.Connected then
			private.players_auto[Player].KeyEvent:Disconnect()
		end
		
		if private.players_auto[Player].InputEvent.Connected then
			private.players_auto[Player].InputEvent:Disconnect()
		end
		
		private.players_auto[Player] = nil
	end
	
	private.players_key_begin[Player] = nil
	private.players_input_begin[Player] = nil
	private.players_key_end[Player] = nil
	private.players_input_end[Player] = nil
end

--[[
	Смотрит в сервисе, есть ли здесь указанный клиент
	
	@class GameIOMappingService
	@side server
	@return boolean
]]
function private:is_player_exists_in_service (Player: Player)
	return private.players_key_end[Player] ~= nil
		or private.players_input_end[Player] ~= nil
		or private.players_key_begin[Player] ~= nil
		or private.players_input_begin[Player] ~= nil
end

--[[
	Смотрит в глобальном словаре, есть ли контекст с таким именем, если есть, возвращает булеан

	@class GameIOMappingService
	@side server
	@return boolean
]]
function private:is_default_context_exists (Context: string)
	local self = self :: GameIOMappingService;
	if private.default_key_end[Context] ~= nil
		or private.default_key_begin[Context] ~= nil
		or private.default_input_end[Context] ~= nil
		or private.default_input_begin[Context] ~= nil then
		return true
	end
	return false
end

--[[
	Смотрит в сервисе контекст с таким именем и возвращает булеан

	@class GameIOMappingService
	@side server
	@return boolean
]]
function private:is_context_exists_in_service (Context: string)
	local self = self :: GameIOMappingService;
	
	if self:IsContextExistsGlobalEvery(Context) then
		return true
	end
	
	for number,list in {private.players_key_end, private.players_input_end, private.players_key_begin, private.players_input_begin} do
		for Player, PlayerTable in list do
			if PlayerTable[Context] then
				return true
			end
		end
	end
	
	return false
end




function private.PLAYER_GLOBAL_get_Controller (Player: Player, Context, State, TableEnd, TableBegin)
	State = private.STATE_get(State)
	return State == private.Map_End and TableEnd[Player][Context]
		or State == private.Map_Begin and TableBegin[Player][Context]
		or interface.Exceptions.CodeException:Throw()
end

function private.DEFAULT_get_Controller (Context: string, State: States, TableEnd, TableBegin)
	State = private.STATE_get(State)
	return State == private.Map_End and TableEnd[Context]
		or State == private.Map_Begin and TableBegin[Context]
		or interface.Exceptions.CodeException:Throw()
end

function private.PLAYER_get_key_Controller (Player: Player, Context: string, State: States)
	return private.PLAYER_GLOBAL_get_Controller(Player, Context, State, private.players_key_end, private.players_key_begin)
end

function private.PLAYER_get_input_Controller (Player: Player, Context:string, State: States)
	return private.PLAYER_GLOBAL_get_Controller(Player, Context, State, private.players_input_end, private.players_input_begin)
end

function private.DEFAULT_get_key_Controller (Context: string, State: States)
	return private.DEFAULT_get_Controller(Context,State,private.default_key_end,private.default_key_begin)
end

function private.DEFAULT_get_input_Controller (Context: string, State: States)
	return private.DEFAULT_get_Controller(Context,State,private.default_input_end,private.default_input_begin)
end




--[[
	Возвращает глобальное событие контекста для игрока с указанным состоянием и ключом.

	@class GameIOMappingService
	@side server
	@return HxEvent
]]
function private:PLAYER_get_key_context_event (Player: Player, Context: string, State: States)
	return private.PLAYER_GLOBAL_get_Controller(Player, Context, State, private.players_key_end, private.players_key_begin).Event
end

--[[
	Возвращает событие контекста для игрока с указанным состоянием и вводом.

	@class GameIOMappingService
	@side server
	@return HxEvent
]]
function private:PLAYER_get_input_context_event (Player: Player, Context: string, State: States)
	return private.PLAYER_GLOBAL_get_Controller(Player, Context, State, private.players_input_end, private.players_input_begin).Event
end

--[[
	Возвращает глобальное событие контекста с указанным состоянием и ключом.

	@class GameIOMappingService
	@side server
	@return HxEvent
]]
function private:DEFAULT_get_key_context_event (Context: string, State: States)
	return private.DEFAULT_get_Controller(Context,State,private.default_key_end,private.default_key_begin).Event
end

--[[
	Возвращает глобальное событие контекста с указанным состоянием и вводом.

	@class GameIOMappingService
	@side server
	@return HxEvent
]]
function private:DEFAULT_get_input_context_event (Context: string, State: States)
	return private.DEFAULT_get_Controller(Context,State,private.default_input_end,private.default_input_begin).Event
end





function private.GLOBAL_create_controller (Function: ( Controller: Controller, Player: Player, EnumItem: EnumItem, State: Enum.UserInputState)->())
	local e0, c0 = HxEvent.new()
	local Controller : Controller = {}  :: any
	local con = NetInputService.Service.OnGlobalKeyInputEvent:Connect(function(...) 
		Function(Controller, ...)
	end)
	
	Controller.Event = e0
	Controller.Control = c0
	Controller.NIS_connection = con
		
	
	
	return Controller
end

function private.DEFAULT_GLOBAL_create_controller (IO, State: States)
	local ExpectedState = private.STATE_get(State)
	local ExpectedState = private.STATE_get(State)
	local Controller = private.GLOBAL_create_controller(function(Controller: Controller, Player: Player, EnumItem: any, State: Enum.UserInputState)   
		if EnumItem == IO and State == ExpectedState then
			if interface.Service:IsLogActive() then
				interface.Service:PrintLog('Global context activated by input')
			end
			Controller.Control.Call(Player)
		end
	end)
	
	Controller.EnumItem = IO
	Controller.State = State
	
	return Controller
end

function private.PLAYER_GLOBAL_create_controller (IO, State: States, Player: Player)
	local ExpectedState = private.STATE_get(State)
	local Activate = function (Controller: Controller)
		if interface.Service:IsLogActive() then
			interface.Service:PrintLog(string.format('%s activate his controller by IO, that reflects to %q in state %q',
				Player.DisplayName, Controller.EnumItem.Name, Controller.State.Name))
		end
		Controller.Control.Call()
	end
	local Controller = private.GLOBAL_create_controller(function(Controller: Controller, GPlayer: Player, EnumItem: any, State: Enum.UserInputState)   
		if Player == GPlayer and State == ExpectedState then
			if Controller.DefaultEnumItem ~= Controller.EnumItem then
				if EnumItem == Controller.EnumItem then
					Activate(Controller)
				end
			else
				if EnumItem == Controller.DefaultEnumItem then
					Activate(Controller)
				end
			end
		
		end
	end)
	
	Controller.DefaultEnumItem = IO
	Controller.EnumItem = IO
	Controller.State = State
	
	return Controller
end







function private.GLOBAL_add_context (Table, Context: string, IO, State: States,  Player: Player?)
	interface.Exceptions.CodeException:Assert(not Table[Context])
	local AddMethode : (...any) -> Controller = (Player and private.PLAYER_GLOBAL_create_controller or private.DEFAULT_GLOBAL_create_controller) :: any
	Table[Context] = AddMethode(IO, State, Player)
	
	if interface.Service:IsLogActive() then
		interface.Service:PrintLog('Context added')
	end
	
	private.c4.Call(Context, State, Player)
end


--[[
	Добавляет контекст сопоставления ключа для конкретного игрока и состояния.

	@class GameIOMappingService
	@side server
	@return ()
]]
function private:PLAYER_add_context_key (Player: Player, Context: string, Key: Enum.KeyCode, State: States)
	local self = self :: GameIOMappingService;
	if not self:IsActive() then return end
	
	if not self:IsPlayerExistsInService(Player) then self:AddPlayerToService(Player) end
	private.GLOBAL_add_context(private.PLAYER_KEY_get(Player, State), Context, Key, State, Player)
end

--[[
	Добавляет контекст сопоставления ввода для конкретного игрока и состояния.

	@class GameIOMappingService
	@side server
	@return ()
]]
function private:PLAYER_add_context_input (Player: Player, Context: string, Input: Enum.UserInputType, State: States)
	local self = self :: GameIOMappingService;
	if not self:IsActive() then return end
	
	if not self:IsPlayerExistsInService(Player) then self:AddPlayerToService(Player) end
	private.GLOBAL_add_context(private.PLAYER_INPUT_get(Player, State), Context, Input, State, Player)
end

--[[
	Добавляет контекст сопоставления ключа для конкретного состояния.

	@class GameIOMappingService
	@side server
	@return ()
]]
function private:DEFAULT_add_context_key (Context: string, Key: Enum.KeyCode, State: States)
	local self = self :: GameIOMappingService;
	if not self:IsActive() then return end
	private.GLOBAL_add_context(private.KEY_get(State), Context,Key,State)
end

--[[
	Добавляет контекст сопоставления ввода для конкретного состояния.

	@class GameIOMappingService
	@side server
	@return ()
]]
function private:DEFAULT_add_context_input (Context: string, Input: Enum.UserInputType, State: States)
	local self = self :: GameIOMappingService;
	if not self:IsActive() then return end
	private.GLOBAL_add_context(private.INPUT_get(State), Context,Input,State)
end






function private.GLOBAL_remove_context (Table, Context, State, Player: Player?)
	local Controller : Controller = interface.Exceptions.CodeException:Assert(Table[Context])
	Controller.Control:Destroy()
	Controller.NIS_connection:Disconnect()
	Table[Context] = nil
	
	if interface.Service:IsLogActive() then
		interface.Service:PrintLog('Context removed')
	end
	
	private.c6.Call(Context, State, Player)
end


--[[
	Удаляет контекст сопоставления ключа для конкретного состояния.

	@class GameIOMappingService
	@side server
	@return ()
]]
function private:DEFAULT_remove_context_key (Context: string, State: States)
	local self = self :: GameIOMappingService;
	if not self:IsActive() then return end
	private.GLOBAL_remove_context(private.KEY_get(State), Context, State)
end


--[[
	Удаляет контекст сопоставления ввода для конкретного состояния.

	@class GameIOMappingService
	@side server
	@return ()
]]
function private:DEFAULT_remove_context_input (Context: string, State: States)
	local self = self :: GameIOMappingService;
	if not self:IsActive() then return end
	private.GLOBAL_remove_context(private.INPUT_get(State), Context, State)
end


--[[
	Удаляет контекст сопоставления ключа для конкретного игрока и состояния.

	@class GameIOMappingService
	@side server
	@return ()
]]
function private:PLAYER_remove_context_key (Player: Player, Context: string, State: States)
	local self = self :: GameIOMappingService;
	if not self:IsActive() then return end
	
	private.GLOBAL_remove_context(private.PLAYER_KEY_get(Player, State), Context, State, Player)
end

--[[
	Удаляет контекст сопоставления ввода для конкретного игрока и состояния.

	@class GameIOMappingService
	@side server
	@return ()
]]
function private:PLAYER_remove_context_input (Player: Player, Context: string, State: States)
	local self = self :: GameIOMappingService;
	if not self:IsActive() then return end
	
	private.GLOBAL_remove_context(private.PLAYER_INPUT_get(Player, State), Context, State, Player)
end


--[[
	Проверяет у игрока, существует ли глобальный контекст сопоставления ключа с указанным состоянием.
	
	@class GameIOMappingService
	@side server
	@return boolean
]]
function private:PLAYER_is_context_exist_key (Player: Player, Context: string, State: States)
	local self = self :: GameIOMappingService;
	return private.PLAYER_KEY_get(Player, State)[Context] ~= nil
end

--[[
	Проверяет у игрока, существует ли глобальный контекст сопоставления ввода с указанным состоянием.
	
	@class GameIOMappingService
	@side server
	@return boolean
]]
function private:PLAYER_is_context_exist_input (Player: Player, Context: string, State: States)
	local self = self :: GameIOMappingService;
	return private.PLAYER_INPUT_get(Player, State)[Context] ~= nil
end

--[[
	Проверяет, существует ли глобальный контекст ключа с указанным состоянием.
	
	@class GameIOMappingService
	@side server
	@return boolean
]]
function private:DEFAULT_is_context_exist_key (Context: string, State: States)
	local self = self :: GameIOMappingService;
	return private.KEY_get(State)[Context] ~= nil
end


--[[
	Проверяет, существует ли глобальный контекст ввода с указанным состоянием.
	
	@class GameIOMappingService
	@side server
	@return boolean
]]
function private:DEFAULT_is_context_exist_input (Context: string, State: States)
	local self = self :: GameIOMappingService;
	return private.INPUT_get(State)[Context] ~= nil
end


--[[
	Возвращает событие, которое срабатывает когда ключ с сопоставимым контекстом был отпущен.

	@class GameIOMappingService
	@side server
	@return HxEvent
]]
function private:GetOnContextKeyEndEvent (Context: string, Player: Player?)
	return Player and private.PLAYER_get_key_Controller(Player, Context, private.Map_End).Event
		or private.DEFAULT_get_key_Controller(Context, private.Map_End).Event
end

--[[
	Возвращает событие, которое срабатывает когда ввод с сопоставимым контекстом был отпущен.

	@class GameIOMappingService
	@side server
	@return HxEvent
]]
function private:GetOnContextInputEndEvent (Context: string, Player: Player?)
	return Player and private.PLAYER_get_input_Controller(Player, Context, private.Map_End).Event
		or private.DEFAULT_get_input_Controller(Context, private.Map_End).Event
end

--[[
	Возвращает событие, которое срабатывает когда ключ с сопоставимым контекстом был нажат.

	@class GameIOMappingService
	@side server
	@return HxEvent
]]
function private:GetOnContextKeyBeginEvent (Context: string, Player: Player?)
	return Player and private.PLAYER_get_key_Controller(Player, Context, private.Map_Begin).Event
		or private.DEFAULT_get_key_Controller(Context, private.Map_Begin).Event
end
--[[
	Возвращает событие, которое срабатывает когда ввод с сопоставимым контекстом был нажат.

	@class GameIOMappingService
	@side server
	@return HxEvent
]]
function private:GetOnContextInputBeginEvent (Context: string, Player: Player?)
	return Player and private.PLAYER_get_input_Controller(Player, Context, private.Map_Begin).Event
		or private.DEFAULT_get_input_Controller(Context, private.Map_Begin).Event
end






private.e4, private.c4 = HxEvent.new();
private.e5, private.c5 = HxEvent.new();
private.e6, private.c6 = HxEvent.new();
private.e7, private.c7 = HxEvent.new();

interface.Enums = table.freeze({
	DenyChanges = Mapping.Enum.DenyChanges;
	AllowChanges = Mapping.Enum.AllowChanges;
});
interface.Exceptions = table.freeze({
	CodeException = Mapping.Exception.CodeException;
	RaceConditionException = Mapping.Exception.RaceConditionException;
	
});
interface.Service = main.Core.Classes.SadNetService().new({ -- 25 методов
	AddPlayerToService = private.PLAYER_add;
	RemovePlayerFromService = private.PLAYER_remove;
	
	GetOnContextKeyEndEvent = private.GetOnContextKeyEndEvent;
	GetOnContextKeyBeginEvent = private.GetOnContextKeyBeginEvent;
	GetOnContextInputEndEvent = private.GetOnContextInputEndEvent;
	GetOnContextInputBeginEvent = private.GetOnContextInputBeginEvent;
	
	GetContextKey = private.DEFAULT_get_key_context_event;
	GetContextInput = private.DEFAULT_get_input_context_event;
	AddContextKey = private.DEFAULT_add_context_key;
	AddContextInput = private.DEFAULT_add_context_input;
	RemoveContextKey = private.DEFAULT_remove_context_key;
	RemoveContextInput = private.DEFAULT_remove_context_input;
	IsContextKeyExist = private.DEFAULT_is_context_exist_key;
	IsContextInputExist = private.DEFAULT_is_context_exist_input;
	

	GetPlayerContextKey = private.PLAYER_get_key_context_event;
	GetPlayerContextInput = private.PLAYER_get_input_context_event;
	AddPlayerContextKey = private.PLAYER_add_context_key;
	AddPlayerContextInput = private.PLAYER_add_context_input;
	RemovePlayerContextKey = private.PLAYER_remove_context_key;
	RemovePlayerContextInput = private.PLAYER_remove_context_input;
	IsPlayerContextKeyExists = private.PLAYER_is_context_exist_key;
	IsPlayerContextInputExists = private.PLAYER_is_context_exist_input;
	
	IsContextExistsGlobalEvery = private.is_default_context_exists;
	IsContextExistsInService = private.is_context_exists_in_service;
	IsPlayerExistsInService = private.is_player_exists_in_service;
	
	OnContextAddedEvent = private.e4;
	OnPlayerContextKeyChangedEvent = private.e5;
	OnPlayerContextInputChangedEvent = private.e7;
	OnContextRemovedEvent = private.e6;
	
	Name = 'GameIOMappingService' :: 'GameIOMappingService';
	IsControllable = true;
	Behavior = interface.Enums.AllowChanges :: index<typeof(interface.Enums), keyof<typeof(interface.Enums)>>;
});

game.Players.PlayerAdded:Connect(function(player: Player)
	local self = interface.Service
	if not self:IsAuto() then return end
	
	if not self:IsPlayerExistsInService(player) then
		self:AddPlayerToService(player)
	end
end)



return interface