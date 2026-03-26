local main = require('../../');
local Mapping = main.Mapping

local NetworkService = main.Core.Services.NetworkService()
local HxSnapshot = main.Core.Classes.HxSnapshot()
local HxSignal = main.Core.Classes.HxSignal()

local private = {}
local interface = {}

type NetInputService = typeof(interface.Service)
export type AwaitedHxSnapshotForKeys = typeof(HxSnapshot.new({EnumKeycode = nil :: Enum.KeyCode?, State = nil :: Enum.UserInputState?}))
export type AwaitedHxSnapshotForCamera = typeof(HxSnapshot.new({CFrame = nil :: CFrame?}))
export type AwaitedHxSnapshotForUserInput = typeof(HxSnapshot.new({UserInputType = nil :: Enum.UserInputType?, State = nil :: Enum.UserInputState?}))

type HxEvent = typeof(private.e0)
type HxEventProperties = typeof(private.global_c_core)
type HxEventConnection = typeof(private.e0:Connect(function() end))
type PlayerController = {Event: HxEvent|any, HxEventControl: HxEventProperties|any, NIS_connection: HxEventConnection, Destroy_Connection: RBXScriptConnection}
type EventsPlayer = {[Player]: PlayerController}

private.players_latest_key = {}
private.players_latest_camera = {}
private.players_latest_userinputtype = {}

private.players_key_event = {} :: EventsPlayer
private.players_camera_event = {} :: EventsPlayer
private.players_userinputtype_event = {} :: EventsPlayer

function private:GetPlayerKeys (player: Player)
	return private.players_latest_key[player] or HxSnapshot.new({EnumKeycode = Enum.KeyCode.W, State = Enum.UserInputState.Begin})
end

function private:GetPlayerUserInput (player: Player)
	return private.players_userinputtype_event[player] or HxSnapshot.new({UserInputType = Enum.UserInputType.MouseButton1, State = Enum.UserInputState.Begin})
end

function private:GetPlayerCameraCFrame (player: Player)
	return private.players_latest_camera[player] or HxSnapshot.new({CFrame = CFrame.new()})
end

function private:is_player_exists_in_service (Player: Player)
	return private.players_latest_key[Player] ~= nil
		or private.players_camera_event[Player] ~= nil
		or private.players_userinputtype_event[Player] ~= nil
		or private.players_key_event[Player] ~= nil
		or private.players_latest_camera[Player] ~= nil
		or private.players_latest_userinputtype[Player] ~= nil
end


function private:GetPlayerKeyChangeEvent (player: Player)
	local self = self :: NetInputService
	if private.players_key_event[player] then
		return private.players_key_event[player].Event
	end
	
	local Controller : PlayerController = {} :: any
	local Core = HxSignal.new(warn::DF_K)
	local Event = Core:AddEvent();
	local con = self.OnGlobalKeyInputEvent:Connect(function(Player: Player, ...) 
		if Player == player then
			Core:DoCall(...)
		end
	end)
	
	Controller.Event = Event
	Controller.HxEventControl = Core
	Controller.NIS_connection = con
	Controller.Destroy_Connection = player.Destroying:Once(function() 
		local alpha = private.players_key_event[player]
		alpha.HxEventControl:Destroy()
		Controller.NIS_connection:Disconnect()
		private.players_key_event[player] = nil
	end)
	private.players_key_event[player] = Controller
	
	return Event
end

function private:GetPlayerCameraChangeEvent (player: Player)
	local self = self :: NetInputService
	if private.players_camera_event[player] then
		return private.players_camera_event[player].Event
	end
	
	local Controller : PlayerController = {} :: any
	local Core = HxSignal.new(warn::DF_C)
	local Event = Core:AddEvent();
	local con = self.OnGlobalCameraEvent:Connect(function(Player: Player, ...) 
		if Player == player then
			Core:DoCall(...)
		end
	end)
	
	Controller.Event = Event
	Controller.HxEventControl = Core
	Controller.NIS_connection = con
	Controller.Destroy_Connection = player.Destroying:Once(function() 
		local alpha = private.players_key_event[player]
		alpha.HxEventControl:Destroy()
		Controller.NIS_connection:Disconnect()
		private.players_key_event[player] = nil
	end)
	private.players_camera_event[player] = Controller
	
	return Event
end	

function private:GetPlayerInputChangeEvent (player: Player)
	local self = self :: NetInputService;
	if private.players_userinputtype_event[player] then
		return private.players_userinputtype_event[player].Event
	end
	
	local Controller : PlayerController = {} :: any
	local Core = HxSignal.new(warn::DF_I);
	local Event = Core:AddEvent();
	local con = self.OnGlobalInputEvent:Connect(function(Player: Player, ...) 
		if Player == player then
			Core:DoCall(...)
		end
	end)
	
	Controller.Event = Event
	Controller.HxEventControl = Core
	Controller.NIS_connection = con
	Controller.Destroy_Connection = player.Destroying:Once(function() 
		local alpha = private.players_key_event[player]
		alpha.HxEventControl:Destroy()
		Controller.NIS_connection:Disconnect()
		private.players_key_event[player] = nil
	end)
	private.players_userinputtype_event[player] = Controller
	
	return Event
end


function private:WatchKey (player: Player)
	local self = self :: NetInputService;
	local this = NetworkService.Service:ForPlayer(player, Mapping.Event.KeyCodeNetwork, function(EI: Enum.KeyCode, State: Enum.UserInputState) 
		if not self:IsActive() then return end
		if self:IsLogActive() then self:PrintLog(string.format('Got %q from %s with content %s, %s', 'KeyCode', player.DisplayName, tostring(EI), tostring(State))) end
		
		main.Mapping.Exception.ClientException:Assert(typeof(EI) == 'EnumItem' and typeof(State) == 'EnumItem')
		
		private.players_latest_key[player] = HxSnapshot.new({
			EnumKeycode = EI;
			State = State;
		})
		
		private.global_k_core:DoCall(player, EI, State)
	end)
	
	player.Destroying:Once(function()
		this:Disconnect()
		private.players_latest_key[player] = nil
	end)
	
	return this :: HxEventConnection
end


function private:WartchUserInputType (player: Player)
	local self = self :: NetInputService;
	local this = NetworkService.Service:ForPlayer(player, Mapping.Event.UserInputNetwork, function(EI: Enum.UserInputType, State: Enum.UserInputState)
		if not self:IsActive() then return end
		if self:IsLogActive() then self:PrintLog(string.format('Got %q from %s with content %s, %s', 'UserInput', player.DisplayName, tostring(EI), tostring(State))) end
		
		main.Mapping.Exception.ClientException:Assert(typeof(EI) == 'EnumItem' and typeof(State) == 'EnumItem')
		
		private.players_latest_userinputtype[player] = HxSnapshot.new({
			UserInputType = EI;
			State = State;
		})
		
		private.global_i_core:DoCall(player, EI, State)
	end)
	
	player.Destroying:Once(function() 
		private.players_latest_userinputtype[player] = nil
	end)
	
	return this :: HxEventConnection
end

function private:WatchCamera (player: Player)
	local self = self :: NetInputService;
	local this = NetworkService.Service:ForPlayer(player, Mapping.Event.CameraNetwork, function(CF: CFrame)
		if not self:IsActive() then return end
		if self:IsLogActive() then self:PrintLog(string.format('Got %q from %s with content %s', 'Camera', player.DisplayName, tostring(CF))) end
		
		main.Mapping.Exception.ClientException:Assert(typeof(CF) == 'CFrame')
		
		private.players_latest_camera[player] = HxSnapshot.new({
			CFrame = CF;
		})
		
		private.global_c_core:DoCall(player, CF)
	end)
	
	player.Destroying:Once(function() 
		private.players_latest_camera[player] = nil
	end)
	
	return this :: HxEventConnection
end

type DF_I = (Player: Player, Input: Enum.UserInputType, State: Enum.UserInputState)->()
type DF_K = (Player: Player, Key: Enum.KeyCode, State: Enum.UserInputState)->()
type DF_C = (Player: Player, CameraCFrame: CFrame) -> ()

private.global_i_core = HxSignal.new(warn::DF_I);
private.global_k_core = HxSignal.new(warn::DF_K);
private.global_c_core = HxSignal.new(warn::DF_C);

private.e0 = private.global_i_core:AddEvent();
private.e5 = private.global_k_core:AddEvent();
private.e6 = private.global_c_core:AddEvent();

interface.Enums = table.freeze({
	Null = Mapping.Enum.Null;
})
interface.Service = main.Core.Classes.SadNetService().new({
	GetPlayerLatestKeyObject = private.GetPlayerKeys;
	GetPlayerLatestUserInputObject = private.GetPlayerUserInput;
	GetPlayerLatestCameraCFrame = private.GetPlayerCameraCFrame;
	
	GetPlayerKeyChangeEvent = private.GetPlayerKeyChangeEvent;
	GetPlayerInputChangeEvent = private.GetPlayerInputChangeEvent;
	GetPlayerCameraChangeEvent = private.GetPlayerCameraChangeEvent;
	
	DoWatchPlayerKeyChangeEvent = private.WatchKey;
	DoWatchPlayerInputChangeEvent = private.WartchUserInputType;
	DoWatchPlayerCameraChangeEvent = private.WatchCamera;
	
	IsPlayerExistsInService = private.is_player_exists_in_service;
	
	OnGlobalInputEvent = private.e0;
	OnGlobalKeyInputEvent = private.e5;
	OnGlobalCameraEvent = private.e6;
	
	Name = 'NetInputService' :: 'NetInputService';
	IsControllable = true;
	Behavior = interface.Enums.Null :: index<typeof(interface.Enums), keyof<typeof(interface.Enums)>>;
});

game.Players.PlayerAdded:Connect(function(player: Player)
	if not interface.Service:IsAuto() then return end
	
	interface.Service:DoWatchPlayerKeyChangeEvent(player)
	interface.Service:DoWatchPlayerInputChangeEvent(player)
	interface.Service:DoWatchPlayerCameraChangeEvent(player)
	
	interface.Service:GetPlayerKeyChangeEvent(player)
	interface.Service:GetPlayerInputChangeEvent(player)
	interface.Service:GetPlayerCameraChangeEvent(player)
end)

return interface