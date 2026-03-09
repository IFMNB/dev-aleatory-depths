local main = require('../../')

local Mapping = main.Mapping

local private = {}
local interface = {}

type NetOwnerService = typeof(interface.Service)

private.forplr = {}

function private:Check (player: Player)
	return not not (private::any).forplr[player]
end

function private:Add (player: Player)
	local self = self :: NetOwnerService;
	
	private.forplr[player] = player.CharacterAdded:Connect(function(character: Model) 
		if not interface.Service:IsActive() then return end
		
		self:SetModelOwnerTo(character, interface.Service.Behavior ~= interface.Enums.Server and player or nil)
	end)
	
	if player.Character then
		self:SetModelOwnerTo(player.Character, interface.Service.Behavior ~= interface.Enums.Server and player or nil)
	end
end

function private.get_model (player: Player)
	local character = Mapping.Exception.CodeException:Assert(player.Character)
	return character
end

function private.get_model_primary (Model: Model|Player)
	local tar : Model
	if Model:IsA('Player') then
		tar = private.get_model(Model)
	elseif Model:IsA('Model') then
		tar = Model
	else
		Mapping.Exception.CodeException:Throw()
	end
	
	return Mapping.Exception.GameException:Assert(tar.PrimaryPart)
end

function private:get_owner (player: Player)
	return private.get_model_primary(player)
end

function private:get_owner_model (Model: Model)
	return Mapping.Exception.GameException:Assert(Model.PrimaryPart):GetNetworkOwner()
end

function private:Set (player: Player, to: typeof(interface.Service.Behavior)?)
	local self = self :: NetOwnerService;
	
	local Primary = private.get_model(player)
	self:SetModelOwnerTo(private.get_model(player), to == interface.Enums.Client and player or nil)
end

function private:SetModelTo (Model: Model, to: Player?)
	local self = self :: NetOwnerService;
	
	local Primary = private.get_model_primary(Model)
	if not Primary:CanSetNetworkOwnership() then return self:PrintLog('Cannot set network ownership') end
	local Owner = Primary:GetNetworkOwner()
	Primary:SetNetworkOwner(to)
	
	if Owner ~= to then
		task.wait(.25)
	end
end

function private:Remove (player: Player)
	local self = self :: NetOwnerService;
	local this = Mapping.Exception.CodeException:Assert(private.forplr[player])
	
	if this.Connected then
		this:Disconnect()
	end
	
	private.forplr[player] = nil

end

function private:Clear ()
	local self = self :: NetOwnerService;
	for i,v in private.forplr do
		if v.Connected then
			v:Disconnect()
		end
	end
	table.clear(private.forplr)
	
	return self
end

-- Swaps the owner of the model to the player. After completing, it will swap it back to the server.
function private:DoFor (Model: Model, F: (Model: Model, Primary: BasePart)->())
	local self = self :: NetOwnerService;
	if not self:IsActive() then return end
	
	local Primary = Mapping.Exception.GameException:Assert(Model.PrimaryPart)
	local owner = Primary:GetNetworkOwner() :: Player
	
	self:SetModelOwnerTo(Model, nil)
	F(Model, Primary)
	self:SetModelOwnerTo(Model, owner)
end

interface.Enums = table.freeze({
	Server = Mapping.Enum.Server;
	Client = Mapping.Enum.Client;
})
interface.Service = main.Core.Classes.SadNetService().new({
	Name = 'NetOwnerService' :: 'NetOwnerService';
	
	-- Инструменты для автоназначения
	Add = private.Add;
	Remove = private.Remove;
	Check = private.Check;
	Clear = private.Clear;
	
	OwnerSwapDo = private.DoFor;
	
	-- Ручное управление
	SetPlayerOwnerTo = private.Set;
	SetModelOwnerTo = private.SetModelTo;
	
	GetPlayerOwner = private.get_owner;
	GetModelOwner = private.get_owner_model;
	
	
	
	IsControllable = true;
	Behavior = interface.Enums.Server :: index<typeof(interface.Enums), keyof<typeof(interface.Enums)>>;
});

game.Players.PlayerAdded:Connect(function(player: Player)
	if not interface.Service:IsActive() then return end
	if not interface.Service:IsAuto() then return end
	interface.Service:Add(player)
end)

return interface