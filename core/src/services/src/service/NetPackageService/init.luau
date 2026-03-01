--!native
--!optimize 2

local main = require('../')

local private = {};
local interface = {};

local PackageTransport = main.ServiceLibs.PackageTransport
type NetPackageService = typeof(interface.Service)
type SadObject = typeof(main.Core.Classes.SadObject().class)
type HxEvent = typeof(main.Core.Classes.HxEvent().new())
type HxEventConnection = typeof(({}::HxEvent):Connect(function(...)  end))

function private.PrepareToSend (...: any)
	local Transport = PackageTransport.Write(...);
	local b, s, B = main.Libs.LarsenBufferize.Table.size({...})
	interface.Service.NetworkWriteSum += B;

	return Transport 
end

function private.GotPackage (Transport: buffer|any)
	if not interface.Service:IsLogActive() then return end
	local size = buffer.len(
		typeof(Transport) == 'buffer' and Transport or buffer.create(0)
	)
	interface.Service.NetworkReadSum += size;
end

--[[
	Отправляет пакет клиенту
	
	@class NetPackageService
	@side server
	@return NetPackageService

]]
function private:SendClient (Player: Player, Event: RemoteEvent|UnreliableRemoteEvent, ...: any)
	interface.Exceptions.CodeException:Assert(game["Run Service"]:IsServer())
	local self = self :: NetPackageService;
	if not self:IsActive() then return self end
	if self:IsLogActive() then
		self:PrintLog(string.format('Sending package to %q', Player.DisplayName))
	end
	
	local Event = Event :: RemoteEvent
	local Transport = private.PrepareToSend(...);
	Event:FireClient(Player, Transport);
	return self
end

--[[
	Отправляет пакет серверу
	
	@class NetPackageService
	@side client
	@return NetPackageService
]]
function private:SendServer (Event: RemoteEvent|UnreliableRemoteEvent, ...: any)
	interface.Exceptions.CodeException:Assert(game["Run Service"]:IsClient())
	local self = self :: NetPackageService;
	local Event = Event :: RemoteEvent
	if not self:IsActive() then return self end
	if self:IsLogActive() then
		self:PrintLog('Sending package to server')
	end
	
	local Transport = private.PrepareToSend(...);
	Event:FireServer(Transport);
	return self
end


--[[
	Отправляет пакет игрокам в списке

	@class NetPackageService
	@side server
	@return NetPackageService
]]
function private:SendPlayers (Players: {Player}, Event: RemoteEvent|UnreliableRemoteEvent, ...: any)
	interface.Exceptions.CodeException:Assert(game["Run Service"]:IsServer())
	local self = self :: NetPackageService;
	local event = Event :: RemoteEvent
	if not self:IsActive() then return self end
	if self:IsLogActive() then
		self:PrintLog(string.format('Sending package to %q players', tostring(#Players)))
	end
	
	for i,v in Players do
		self:SendClient(v, event, ...);
	end
	return self
end

--[[
	Отправляет пакет всем игрокам

	@class NetPackageService
	@side server
	@return NetPackageService
]]
function private:SendAllClients (Event: RemoteEvent|UnreliableRemoteEvent, ...: any)
	local self = self :: NetPackageService;
	if self:IsLogActive() then
		self:PrintLog('Sending package to all clients')
	end
	self:SendToClients(game.Players:GetPlayers(),Event, ...)
	return self
end

private.watched = {}::{[RemoteEvent|UnreliableRemoteEvent]: HxEvent}


--[[
	Создает или возвращает HxEvent для события. Событие вызывается каждый раз, когда на локальной машине получается пакет.
	
	@class NetPackageService
	@side all
	@exception *unknown*, SafetyException
	@return HxEvent
]]
function private:WatchEvent (Event: RemoteEvent|UnreliableRemoteEvent) : HxEvent
	local self = self :: NetPackageService;
	local event = Event :: RemoteEvent;
	
	
	
	if self:IsLogActive() then
		self:PrintLog(`Watched event {event.Name}`)
	end
	
	if private.watched[event] then
		return private.watched[event]
	end
	
	local HxEvent, HxEControll = main.Core.Classes.HxEvent().new();
	
	local con : RBXScriptConnection
	event.Destroying:Once(function() 
		private.watched[event]=nil
		con:Disconnect()
	end)
	
	if game["Run Service"]:IsServer() then
		con = event.OnServerEvent:Connect(function(player: Player, Transport: buffer|{})
			if not self:IsActive() then return end
			local this
			
			private.GotPackage(Transport)
			
			if typeof(Transport) == 'buffer' then
				this = PackageTransport.Read(Transport)
			else
				interface.Exceptions.SafetyException:Throw()
			end
			
			if type(this) == 'table' then
				HxEControll.Call(player, unpack(this))
			else
				HxEControll.Call(player,this)
			end
		end)
	else
		con = event.OnClientEvent:Connect(function(Transport: buffer|{})
			if not self:IsActive() then return end
			local this
			
			private.GotPackage(Transport)
			
			if typeof(Transport) == 'buffer' then
				this = PackageTransport.Read(Transport)
			else
				interface.Exceptions.SafetyException:Throw()
			end
			
			if type(this) == 'table' then
				HxEControll.Call(unpack(this))
			else
				HxEControll.Call(this)
			end
		end)
	end
	
	private.watched[event] = HxEvent;
	
	return HxEvent
end


--[[
	Соединение ожидает пока вызов придет от конкретного игрока и выполняет callback.
	
	Во избежание дублирования одного и того же кода на разных сервисах этот метод доступен для вызова даже на HxEvent.

	@class NetPackageService
	@side server
	@return HxEventConnection (Connection)
]]
function private:forplayer (Player: Player, Event: RemoteEvent|UnreliableRemoteEvent|HxEvent, F: (...any)->(), Once: boolean?)
	interface.Exceptions.CodeException:Assert(game["Run Service"]:IsServer())
	local self = self :: NetPackageService;
	local con : HxEventConnection
	
	local function lambda (player: Player, ... : any)
		if not self:IsActive () then
			return
		end
		
		if player == Player then
			F(...)
			if Once then
				con:Disconnect()
			end
			if self:IsLogActive() then
				self:PrintLog(`Forplayer called by player {player.Name}`)
			end
		end
	end
	
	if (Event::any):IsA('SadObject') then
		local Event = Event :: HxEvent
		Event:Connect(lambda)
	else
		local Event = Event :: RemoteEvent|UnreliableRemoteEvent
		con = self:ForEvent(Event):Connect(lambda)
	end
	
	return con
end


--[[
	Ожидает пока пакет придет от конкретного игрока, замораживая поток.
	
	@class NetPackageService
	@side server
	@return variadic
]]
function private:waitplayer (Player: Player, Event: RemoteEvent|UnreliableRemoteEvent, timeout: number?)
	local self = self :: NetPackageService;
	local thread = coroutine.running()
	
	local con : any
	local this = task.spawn(function ()
		task.wait(timeout or self.Timeout)
		if con then
			con:Disconnect()
		end
		
		coroutine.close(thread)
		main.Mapping.Exception.ClientException:Throw()
	end)
	
	con = self:ForPlayer(Player, Event, function(Data: {any}) 
		task.cancel(this)
		coroutine.resume(thread, Data)
		con:Disconnect()
	end)
	
	return coroutine.yield()
end


interface.Enums = table.freeze({
	UseBufferedTransport = main.Mapping.Enum.UseBufferedTransport;
})
interface.Exceptions = table.freeze({
	NetworkException = main.Mapping.Exception.NetworkException,
	CodeException = main.Mapping.Exception.CodeException,
	SafetyException = main.Mapping.Exception.SafetyException,
})
interface.Service = main.Core.Classes.SadNetService().new({
	SendClient = private.SendClient;
	SendServer = private.SendServer;
	SendToClients = private.SendPlayers;
	SendAllClients = private.SendAllClients;
	
	ForEvent = private.WatchEvent;
	ForPlayer = private.forplayer;
	WaitPlayer = private.waitplayer;
	
	Name = 'NetPackageService'::'NetPackageService',
	
	IsControllable = false;
	Timeout = 5;
	LoggerTime = 2;
	NetworkReadSum = 0;
	NetworkWriteSum = 0;
	Behavior = interface.Enums.UseBufferedTransport :: index<typeof(interface.Enums), keyof<typeof(interface.Enums)>>;
})

local function logger ()
	local saved_Read, saved_write = 0,0
	local thread = coroutine.running()
	local DeltaTime = os.time()
	
	task.defer(function ()
		interface.Service.OnLogActiveChangedEvent:Once(function(...) 
			coroutine.close(thread)
		end)
	end)
	
	while task.wait(interface.Service.LoggerTime) do
		interface.Service:PrintLog(string.format('NetworkByteLogStamp\nRead %q, Write %q\nDeltaRead %q, DeltaWrite %q\nServiceTimeout %s, StampDeltaTime %s ',
			tostring(interface.Service.NetworkReadSum),
			tostring(interface.Service.NetworkWriteSum),
			tostring(interface.Service.NetworkReadSum - saved_Read),
			tostring(interface.Service.NetworkWriteSum - saved_write),
			tostring(interface.Service.LoggerTime),
			tostring(os.time()-DeltaTime)
			))
		saved_Read, saved_write = interface.Service.NetworkReadSum, interface.Service.NetworkWriteSum
		DeltaTime = os.time()
	end
end

if interface.Service:IsActive() then
	task.spawn(logger)
else
	interface.Service.OnLogActiveChangedEvent:Connect(logger)
end

return interface