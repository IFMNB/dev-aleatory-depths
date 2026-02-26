local main = require('./');

local Hx = main.Libs.Hexagon
local HxEvent = Hx.Classes.HxEvent()

local private = {};
local class = {}; setmetatable(class, class);
local protected = {};
local interface = {};

type SadAbstractCharacter = typeof(class)
type ControllerSides = index<typeof(main.Mapping.Enum.CharacterController), keyof<typeof(main.Mapping.Enum.CharacterController)>>

private.mode = {__mode='k'}
private.controller = setmetatable({} :: {[SadAbstractCharacter]: ControllerSides }, private.mode)
private.controller_active = setmetatable({} :: {[SadAbstractCharacter]: boolean}, private.mode)
private.downed = setmetatable({} :: {[SadAbstractCharacter]: boolean}, private.mode)
private.team = setmetatable({} :: {[SadAbstractCharacter]: string}, private.mode)

-- Returns the team of the character.
function private:GetTeam ()
	local self = self :: SadAbstractCharacter;
	return private.team[self] or ''
end
-- Returns the controller of the character.
function private:GetController ()
	local self = self :: SadAbstractCharacter;
	return private.controller[self] or main.Mapping.Enum.CharacterController.ScenarioSide
end
-- Returns true if the controller is active.
function private:IsControllerActive ()
	local self = self :: SadAbstractCharacter;
	return not not private.controller_active[self]
end
-- Returns true if the character is downed.
function private:IsDowned ()
	local self = self :: SadAbstractCharacter;
	return not not private.downed[self]
end
-- Sets the controller of the character.
function private:SetController (side: ControllerSides)
	local self = self :: SadAbstractCharacter;
	private.controller[self] = side
end
-- Sets the controller active of the character.
function private:SetControllerActive (active: boolean)
	local self = self :: SadAbstractCharacter;
	private.controller_active[self] = active
end
-- Sets the downed state of the character.
function private:SetDowned (downed: boolean)
	local self = self :: SadAbstractCharacter;
	private.downed[self] = downed
end
-- Sets the team of the character.
function private:SetTeam (team: string)
	local self = self :: SadAbstractCharacter;
	private.team[self] = team
end



function private.CreateSACNode (Char: Model)
	local GameException = main.Mapping.Exception.GameException
	return GameException:Assert(Char.PrimaryPart), GameException:Assert(Char), GameException:Assert(Char:FindFirstChildOfClass('Humanoid'))
end

protected.NewNode = private.CreateSACNode;

class.__index = main.SadObject.class;
class.ClassName = main.Mapping.Class.SadAbstractCharacter
class.Source = script;

class.Root = nil :: BasePart?
class.Model = nil :: Model?
class.Humanoid = nil :: Humanoid?

class.ReviveTime = 1
class.DownedDieTime = 10
class.Revives = 3
class.GetTeam = private.GetTeam;
class.GetController = private.GetController;
class.SetTeam = private.SetTeam;
class.SetController = private.SetController;
class.SetControllerActive = private.SetControllerActive;
class.SetDowned = private.SetDowned;
class.IsControllerActive = private.IsControllerActive;
class.IsDowned = private.IsDowned;

private.e0, private.c0 = HxEvent.new();private.c0:Destroy();
class.OnControllerChangedEvent = private.e0
class.OnDownedEvent = private.e0
class.OnReviveEvent = private.e0
class.OnDiedEvent = private.e0
class.OnTeamChangeEvent = private.e0

interface.class = class

return main:expand({__SadAbstractCharacter = interface, __SadAbstractCharacter_protected = protected})