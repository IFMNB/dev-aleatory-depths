local main = require('../../');

local Hx = main.Libs.Hexagon
local HxEvent = Hx.Classes.HxEvent()
local SadCharacterReference = require('./SadCharacterReference').SadCharacterReference
local SadCharacterProperties = require('./SadCharacterProperties').SadCharacterProperties

local private = {};
local class = {}; setmetatable(class, class);
local protected = {}; 
local interface = {};

type SadAbstractCharacter = typeof(class)
type SadCharacterReference <SCR1=any,SCR2=any,SCR3=any> = typeof(SadCharacterReference.new(nil::SCR1))
export type SadCharacterProperties = typeof(SadCharacterProperties.new())
type ControllerSides = index<typeof(main.Mapping.Enum.CharacterController), keyof<typeof(main.Mapping.Enum.CharacterController)>>

private.mode = {__mode='k'}
private.controller = setmetatable({} :: {[SadAbstractCharacter]: ControllerSides }, private.mode)
private.controller_active = setmetatable({} :: {[SadAbstractCharacter]: boolean}, private.mode)
private.downed = setmetatable({} :: {[SadAbstractCharacter]: boolean}, private.mode)
private.team = setmetatable({} :: {[SadAbstractCharacter]: string}, private.mode)
private.died = setmetatable({} :: {[SadAbstractCharacter]: boolean}, private.mode)

--[[
	Обычный геттер для получения аттрибута команды персонажа.

	@class SadAbstractCharacter
	@side all
	@return string
]]
function private:GetTeam ()
	local self = self :: SadAbstractCharacter;
	return private.team[self] or ''
end
--[[
	Геттер для получения текущего энумератора контроллера или того что его заменяет.
	
	@class SadAbstractCharacter
	@side all
	@return Enum.CharacterController | Enum.CharacterController.ScenarioSide | any
]]
function private:GetController ()
	local self = self :: SadAbstractCharacter;
	return private.controller[self] or main.Mapping.Enum.CharacterController.ScenarioSide
end
--[[
	Обычный геттер чтобы узнать состояние "контроллера активен".
	
	@class SadAbstractCharacter
	@side all
	@return boolean
]]
function private:IsControllerActive ()
	local self = self :: SadAbstractCharacter;
	return not not private.controller_active[self]
end
--[[
	Обычный геттер чтобы узнать состояние "уронили".

	@class SadAbstractCharacter
	@side all
	@return boolean
]]
function private:IsDowned ()
	local self = self :: SadAbstractCharacter;
	return not not private.downed[self]
end

--[[
	В ряде сценариев помогает обозначить управляющий контроллер персонажа.
	
	В этом же числе позволяет определять синглтон контроллеры или сценарные
	события. В некоторых случаях заблокирован. См. контракт класса.

	@class SadAbstractCharacter
	@side all
	@return ()
	
	@usage
		character.OnControllerChangedEvent:Connect(warn) -- выведет энумераторы, замените на любую функцию
		character:SetController(main.Mapping.Enum.CharacterController.PlayerSide)
		character:SetController(main.Mapping.Enum.CharacterController.ScenarioSide)
]]
function private:SetController (side: ControllerSides)
	local self = self :: SadAbstractCharacter;
	private.controller[self] = side
end

--[[
	Сигнализирует на активность управления над персонажем.

	@class SadAbstractCharacter
	@side all
	@return ()
	
	@usage
		character.OnControllerActive:Connect(warn) -- выведет true, замените на любую функцию
		character:SetControllerActive(true)
]]
function private:SetControllerActive (active: boolean)
	local self = self :: SadAbstractCharacter;
	private.controller_active[self] = active
end

--[[
	Состояние "уронен" указывает на событие утраты 1 жизни или что-либо другое.
	
	Под этим состоянием подразумевается тот факт, что данный персонаж временно или
	на постоянной основе лишается полного контроля.
	
	@class SadAbstractCharacter
	@side all
	@return ()
	
	@usage
		character.OnDownedEvent:Connect(warn) -- выведет true, замените на любую функцию
		character:SetDowned(true)
]]
function private:SetDowned (downed: boolean)
	local self = self :: SadAbstractCharacter;
	private.downed[self] = downed
end

--[[
	Устанавливает аттрибут команды персонажа
	
	@class SadAbstractCharacter
	@side all
	@exception CodeException
	@return ()
	
	@usage
		local team = character:GetTeam() -- 'Blue'
		character:SetTeam('Red') -- теперь 'Red'
]]
function private:SetTeam (team: string)
	local self = self :: SadAbstractCharacter;
	private.team[self] = team
end


--[[
	Активирует неизменяемое событие смерти персонажа.
	
	@class SadAbstractCharacter
	@side all
	@exception CodeException
	@return ()
]]
function private:Die ()
	local self = self :: SadAbstractCharacter;
	private.died[self] = true
end

--[[
	Возвращает непереписываемое состояние персонажа о том, мертв ли он сейчас или нет.
	
	@class SadAbstractCharacter
	@side all
	@exception CodeException
	@return boolean
]]
function private:GetDie ()
	local self = self :: SadAbstractCharacter;
	return not not private.died[self]
end

--[[
	Активирует событие оживления персонажа, если у него остались жизни, иначе убивает его.
	
	@class SadAbstractCharacter
	@side all
	@exception CodeException
	@return ()
]]
function private:Revive ()
	local self = self :: SadAbstractCharacter;
	local Properties = main.Mapping.Exception.CodeException:Assert(self.Properties)
	Properties.Revives -= 1
	if Properties.Revives < 0 then
		self:DoDie()
	end
end

--[[
	Устанавливает абстрактные свойства для переданного элемента.

	@class SadAbstractCharacter
	@side all
	@exception CodeException
	@return SadObject
]]
function private.Construct <T,Y> (character: Model?, element: T, childClass: Y, pre_defined: SadCharacterProperties?)
	local SadCharacterReference = SadCharacterReference.new(character or class.Reference.Model:Clone())
	
	local e0, c0 = HxEvent.new();
	local e1, c1 = HxEvent.new();
	local e2, c2 = HxEvent.new();
	local e3, c3 = HxEvent.new();
	local e4, c4 = HxEvent.new();
	local e5, c5 = HxEvent.new();
--	local e6, c6 = HxEvent.new();
	
	local this = main.new(element, childClass)
	local nolint = this :: any
	
	nolint.Reference = SadCharacterReference;
	nolint.Properties = pre_defined or SadCharacterProperties.new();
	
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

protected.Construct = private.Construct;

class.__index = main.Core.Classes.SadObject().class;
class.ClassName = main.Mapping.Class.SadAbstractCharacter
class.Source = script;

class.Reference = table.freeze(SadCharacterReference.new(script.Parent.Parent.models.err_mdl:Clone()));
class.Properties = table.freeze(SadCharacterProperties.new());

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