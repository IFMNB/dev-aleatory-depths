local main = require('../')

local Mapping = main.Mapping
local NetPackageService = main.Core.Services.NetPackageService()

local private = {}
local interface = {}

--local CoordinateNetEvent = main.Classes.SadNetworkEvent().new(Mapping.Event.CoordinateNetwork)
type NetCoordinateService = typeof(interface.Service)
private.forplr = {}

function private:Check (player: Player)
	return not not (private::any).forplr[player]
end

function private:Send (player: Player, deltaTime: number?)
	local self = self :: NetCoordinateService;
	if not self:IsActive() then return end
	local character = player.Character :: Model;
	if not character then
		interface.Exceptions.GameException:Warn('Character not found')
		return
	end
	
	if self:IsLogActive() then
		local time = os.clock()
		self:PrintLog(string.format('For player with Delta time %s, LS %q', deltaTime and tostring(deltaTime) or 'NEVER', tostring(time-self.LastSendedCoordinateTime)))
		self.LastSendedCoordinateTime = time
	end
	local cframe : CFrame
	
	if self.Behavior == interface.Enums.Client then
		-- TODO
		interface.Exceptions.CodeException:Throw()
		return
	end
	
	cframe = character:GetPivot()
	
	NetPackageService.Service:SendClient(player, Mapping.Event.CoordinateNetwork, cframe.Position,cframe.LookVector,cframe.UpVector)
	return
end

function private:Add (player: Player)
	local self = self :: NetCoordinateService;
	local this = {}
	
	Mapping.Exception.CodeException:Assert(not self:IsPlayerInService(player))
	
	this.lambda = nil :: RBXScriptConnection?;
	this.added = player.CharacterAdded:Connect(function(character: Model) 
		this.lambda = game["Run Service"].Heartbeat:Connect(function(deltaTime: number)
			self:DoSendCoordinate(player, deltaTime)
		end)
	end)
	
	this.removed = player.CharacterRemoving:Connect(function(character: Model) 
		if this.lambda then
			if this.lambda.Connected then
				this.lambda:Disconnect()
				this.lambda = nil
			end
		end
	end)
	
	this.destroy = player.Destroying:Once(function() 
		self:Remove(player)
	end)
	private.forplr[player]=this
	
	return self
end

function private:Remove (player: Player)
	local self = self :: NetCoordinateService;
	local this =  Mapping.Exception.CodeException:Assert(private.forplr[player])
	
	if this.lambda then
		if this.lambda.Connected then
			this.lambda:Disconnect()
		end
	end
	
	if this.destroy then
		if this.destroy.Connected then
			this.destroy:Disconnect()
		end
	end
	
	this.added:Disconnect()
	this.removed:Disconnect()
	
	private.forplr[player]=nil
	
	return self
end
-- Clear all players
function private:Clear ()
	local self = self :: NetCoordinateService;
	for i,v in private.forplr do
		self:Remove(i)
	end
	
	return self
end



interface.Enums = table.freeze({
	Server = Mapping.Enum.Server;
	Client = Mapping.Enum.Client;
});
interface.Exceptions = table.freeze({
	GameException = Mapping.Exception.GameException;
	CodeException = Mapping.Exception.CodeException;
});
interface.Service = main.Core.Classes.SadNetService().new({

	Add = private.Add;
	Remove = private.Remove;
	IsPlayerInService = private.Check;
	DoClearPlayers = private.Clear;
	DoSendCoordinate = private.Send;
	LastSendedCoordinateTime = 0;
	
	Name = 'NetCoordinateService' :: 'NetCoordinateService';
	IsControllable = true;
	Behavior = interface.Enums.Server  :: index<typeof(interface.Enums), keyof<typeof(interface.Enums)>>;
});

game.Players.PlayerAdded:Connect(function(player: Player) 
	if not interface.Service:IsActive() then return end
	if not interface.Service:IsAuto() then return end
	interface.Service:Add(player)
end)

return interface