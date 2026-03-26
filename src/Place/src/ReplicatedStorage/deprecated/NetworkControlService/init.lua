local gl = require('./')

local cor = gl.Library.CodeBox.Special.Coroutine()
local instance = gl.Library.Hexagon.Classes.Instance()

local event = gl.Library.AllPath.Services.core_client.NetOwnerService.RemoteEvent


local private = {}
local service

private.partscc = {} :: {[BasePart]: RBXScriptConnection}
private.conscc = {} :: {[Player]: RBXScriptConnection}
private.service = {}
service = instance.new(private.service, 'NetworkControlService'::'NetworkControlService')

private.service.NetworkChangeTime = 1

type asw = typeof(cor._typecheck.asyncwait)

-- Performs the function as if the NetworkOwner belonged to the server, returning the original NetworkOwner back after execution
function private:SwapReturn <t0> (object: (Model|BasePart)&t0, F: asw)
	local element = object:IsA('BasePart') and object or assert((object::Model).PrimaryPart, 'Model does not have a PrimaryPart')
	local player = element:GetNetworkOwner() :: Player?
	
	element:SetNetworkOwner();
	cor.Async(F);
	task.wait(private.service.NetworkChangeTime);
	element:SetNetworkOwner(player);
	
	return object :: t0
end
-- Performs the function as if the NetworkOwner belonged to this player, returning the original NetworkOwner back after execution
function private:SwapGo  <t0> (player: Player, object: (Model|BasePart)&t0, F: asw)
	local element = object:IsA('BasePart') and object or assert((object::Model).PrimaryPart, 'Model does not have a PrimaryPart')
	local owner = element:GetNetworkOwner() :: Player?
	
	element:SetNetworkOwner(player); 
	cor.Async(F);
	task.wait(private.service.NetworkChangeTime)
	element:SetNetworkOwner(owner);
	
	return object :: t0
end

type Sides = 'Client' | 'Server'

-- Controls character position frequency updater. Much better than use default rbx replicator, because this thing protects us from every cheat and provides better replication.
function private:SwapCharacterControl (player: Player, Side: Sides)
	local char = player.Character or player.CharacterAdded:Wait()
	if char then
		local root = assert(char.PrimaryPart, 'Character model should have a PrimaryPart.')
		root:SetNetworkOwner(Side == 'Client' and player or nil)
		if Side == 'Server' then
			player.Destroying:Once(function() 
				if private.conscc[player] then
					private.conscc[player]:Disconnect()
					private.conscc[player] = nil
				end
			end)
			
			private.conscc[player] = game["Run Service"].Heartbeat:Connect(function(deltaTimeSim: number) 
				local char = player.Character
				if char then
					local root = char.PrimaryPart
					if root then
						root:SetNetworkOwner()
						event:FireClient(player, 'CharacterChange', root.CFrame)
					end
				end
			end)
		else
			if private.conscc[player] then
				event:FireClient(player, 'CharacterChangeOver')
				private.conscc[player]:Disconnect()
				private.conscc[player] = nil
			end
		end
	end
end
-- Controls part position frequency updater.
function private:SwapPartUpdater (part: BasePart, player: Player?)
	if private.partscc[part] then
		private.partscc[part]:Disconnect()
		private.partscc[part] = nil
	end
	
	if player then
		private.partscc[part] = game["Run Service"].PostSimulation:Connect(function(deltaTimeSim: number) 
			event:FireClient(player, 'PartCFrameChange', part, part.CFrame)
		end)
	end
end

type Info = 'CharacterChange' | 'PartCFrameChange' | 'CharacterChangeOver'

private.service.CallOnServerSide = private.SwapReturn
private.service.CallOnClientSide = private.SwapGo
private.service.SetCharacterReplicaType = private.SwapCharacterControl
private.service.SetPartReplicaType = private.SwapPartUpdater

return service :: typeof(service) & {
	_typecheck: {
		InfoTypes: Info
	}
}