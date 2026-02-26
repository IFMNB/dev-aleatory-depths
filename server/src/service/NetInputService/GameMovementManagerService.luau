local main = require('../..')
local Mapping = main.Mapping

local private = {};
local interface = {};

local NetInputService = require('./')

type GameMovementService = typeof(interface.Service)
type KeyObject <PlayerT=Player> = typeof(assert(NetInputService.Service:GetPlayerKeyObject(nil::PlayerT)))

function private:Move (Character: Model | Humanoid, Direction: Vector3, cameraRelative: boolean?)
	local self = self :: GameMovementService;
	if not self:IsActive() then return end
	
	local Humanoid : Humanoid
	
	if Character:IsA('Model') then
		Humanoid = interface.Exceptions.GameException:Assert(Character:FindFirstChildOfClass('Humanoid'))
	elseif Character:IsA('Humanoid') then
		Humanoid = Character
	else
		interface.Exceptions.GameException:Throw()
	end
	
	Humanoid:Move(Direction, cameraRelative)
end

interface.Enums = table.freeze({
	
});
interface.Exceptions = table.freeze({
	GameException = Mapping.Exception.GameException;
	CodeException = Mapping.Exception.CodeException;
});
interface.Service = main.Core.Classes.SadNetService().new({
	Name = 'GameMovementService';
	IsControllable = true;
	Behavior = {};
});

NetInputService.Service.OnKeyInput:Connect(function(player: Player, KeyObject: KeyObject) 
	if not interface.Service:IsAuto() then return end
	
	if KeyObject.Snapshot.EnumKeycode == Enum.KeyCode.W then
		
	end
	
end)


return interface