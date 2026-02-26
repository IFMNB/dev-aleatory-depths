local main = require('../')

local private = {};
local interface = {};

local PackageTransport = main.ServiceLibs.PackageTransport
local Http = game:GetService('HttpService')


-- TODO
-- Ревизия Net API (избавиться от Net классов и оставить 1 этот сервис)

type NetPackageService = typeof(interface.Service)
type SadObject = typeof(main.Core.Classes.SadObject().class)
type HxEvent = typeof(main.Core.Classes.HxEvent().new())

function private.PrepareToSend (...: any)
	local Transport = PackageTransport.Write(...);
	local b, s, B = main.Libs.LarsenBufferize.Table.size({...})
	interface.Service.NetworkWriteSum += B;
	
	if interface.Service:IsLogActive() then
		interface.Service:PrintLog(
			string.format('Writed %q byte value, #wsum == %q', tostring(B), tostring(interface.Service.NetworkWriteSum)))
	end

	return Transport 
end

function private.GotPackage (Transport: buffer|any)
	if not interface.Service:IsLogActive() then return end
	local size = buffer.len(
		typeof(Transport) == 'buffer' and Transport or buffer.create(0)
	)
	interface.Service.NetworkReadSum += size;
	interface.Service:PrintLog(string.format('Got package with byte size %q, #rsum == %q',
		tostring(
			size
		),
		tostring(interface.Service.NetworkReadSum)
		)
	)
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
	self:SendToClients(game.Players:GetPlayers(),Event, ...)
	return self
end

private.watched = {}::{[RemoteEvent|UnreliableRemoteEvent]: HxEvent}


--[[
	Создает или возвращает HxEvent для события. Событие вызывается каждый раз, когда на локальной машине получается пакет.
	
	@class NetPackageService
	@side all
	@return HxEvent
	@exception ?

]]
function private:WatchEvent (Event: RemoteEvent|UnreliableRemoteEvent) : HxEvent
	local self = self :: NetPackageService;
	local event = Event :: RemoteEvent;
	
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
				this = Transport
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
				this = Transport
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
	Соединение ожидает пока пакет придет от конкретного игрока и выполняет callback.

	@class NetPackageService
	@side server
	@return HxEventConnection (Connection)
]]
function private:forplayer (Player: Player, Event: RemoteEvent|UnreliableRemoteEvent, F: (...any)->())
	interface.Exceptions.CodeException:Assert(game["Run Service"]:IsServer())
	local self = self :: NetPackageService;
	local con : any
	con = self:ForEvent(Event):Connect(function(player: Player, ...: any) 
		if player == Player then
			F(...)
		end
	end)
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
	
	local con
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
	NetworkReadSum = 0;
	NetworkWriteSum = 0;
	Behavior = interface.Enums.UseBufferedTransport :: index<typeof(interface.Enums), keyof<typeof(interface.Enums)>>;
})

return interface