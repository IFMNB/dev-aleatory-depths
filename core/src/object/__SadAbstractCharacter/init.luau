local main = require('./');

local Hx = main.Libs.Hexagon
local HxEvent = Hx.Classes.HxEvent()
local SadCharacterReference = require('./SadCharacterReference').SadCharacterReference

local private = {};
local class = {}; setmetatable(class, class);
local protected = {};
local interface = {};

type SadAbstractCharacter = typeof(class)
type SadCharacterReference = typeof(SadCharacterReference.class)
type ControllerSides = index<typeof(main.Mapping.Enum.CharacterController), keyof<typeof(main.Mapping.Enum.CharacterController)>>

private.mode = {__mode='k'}
private.controller = setmetatable({} :: {[SadAbstractCharacter]: ControllerSides }, private.mode)
private.controller_active = setmetatable({} :: {[SadAbstractCharacter]: boolean}, private.mode)
private.downed = setmetatable({} :: {[SadAbstractCharacter]: boolean}, private.mode)
private.team = setmetatable({} :: {[SadAbstractCharacter]: string}, private.mode)
private.died = setmetatable({} :: {[SadAbstractCharacter]: boolean}, private.mode)

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

function private:Die ()
	local self = self :: SadAbstractCharacter;
	private.died[self] = true
end

function private:GetDie ()
	local self = self :: SadAbstractCharacter;
	return not not private.died[self]
end

function private:Revive ()
	local self = self :: SadAbstractCharacter;
	self.Revives -= 1
	if self.Revives < 0 then
		self:DoDie()
	end
end

--[[
	

]]
function private.Construct <T,Y> (character: Model, element: T, childClass: Y)
	local SadCharacterReference = SadCharacterReference.new(character)
	
	local e0, c0 = HxEvent.new();
	local e1, c1 = HxEvent.new();
	local e2, c2 = HxEvent.new();
	local e3, c3 = HxEvent.new();
	local e4, c4 = HxEvent.new();
	local e5, c5 = HxEvent.new();
--	local e6, c6 = HxEvent.new();
	
	local this = main.new(element, class)
	local nolint = this :: any
	
	nolint.Reference = SadCharacterReference;
	nolint.SetTeam = main.Abstract.Wrap(c0.Call, class.SetTeam);
	nolint.SetController = main.Abstract.Wrap(c1.Call, class.SetController);
	nolint.SetControllerActive = main.Abstract.Wrap(c2.Call, class.SetControllerActive);
	nolint.SetDowned = main.Abstract.Wrap(c3.Call, class.SetDowned);
	
	nolint.DoDie = main.Abstract.Wrap(c4.Call, class.DoDie);
	nolint.DoRevive = main.Abstract.Wrap(c5.Call, class.DoRevive);
	
	nolint.OnTeamChangedEvent = e0;
	nolint.OnControllerActiveChangedEvent = e2;
	nolint.OnControllerChangedEvent = e1;
	nolint.OnDownedEvent = e3;
	nolint.OnDiedEvent = e4;
	nolint.OnReviveEvent = e5;
	
	return this
end

type DefaultCanDefine = {
	ReviveTime: number,
	DownedDieTime: number,
	DownedReviveTime: number,
}

protected.Construct = private.Construct;

class.__index = main.SadObject.class;
class.ClassName = main.Mapping.Class.SadAbstractCharacter
class.Source = script;

class.Refenrence = nil :: SadCharacterReference?;
class.ReviveTime = 1
class.DownedDieTime = 10
class.Revives = 3

class.GetTeam = private.GetTeam;
class.GetController = private.GetController;

class.DoDie = private.Die;
class.DoRevive = private.Revive;
	
class.SetTeam = private.SetTeam;
class.SetController = private.SetController;
class.SetControllerActive = private.SetControllerActive;
class.SetDowned = private.SetDowned;


class.IsControllerActive = private.IsControllerActive;
class.IsDowned = private.IsDowned;
class.IsDead = private.GetDie;

private.e0, private.c0 = HxEvent.new();private.c0:Destroy();
class.OnControllerChangedEvent = private.e0
class.OnDownedEvent = private.e0
class.OnReviveEvent = private.e0
class.OnDiedEvent = private.e0
class.OnTeamChangeEvent = private.e0

interface.class = class

return main:expand({__SadAbstractCharacter = interface, __SadAbstractCharacter_protected = protected})