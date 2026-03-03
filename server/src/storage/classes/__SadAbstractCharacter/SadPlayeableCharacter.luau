local main = require('./');

local Hx = main.Libs.Hexagon
local HxEvent = Hx.Classes.HxEvent()
local SadAbstractCharacter_protected = main.__SadAbstractCharacter_protected
local Mapping = main.Mapping

local private = {};
local class = {}; setmetatable(class, class);
local interface = {};

private.linked = setmetatable({}, {__mode='k'})
type HxEvent = typeof(HxEvent.class)
type SadPlayerCharacter = typeof(class);

--[[
	Создает экземпляр игрового управляемого перссонажа.
	
	Подразумевается, что контроллер этого персонажа никогда не подчиняется ни Ai, ни Scenario.

	@class SadPlayerCharacter
	@side all
	@exception CodeException
	@return SadPlayerCharacter
]]
function private.new (Character: Model, Params: main.DefaultCanDefine?, Player: Player?)
	local e0, c0 = HxEvent.new(class.ClassName);
	
	
	local this = SadAbstractCharacter_protected.Construct(Character, {
		SetCharacterPlayer = main.Abstract.Wrap(c0.Call, class.SetCharacterPlayer);
		OnCharacterPlayerChanged = e0;
	}, class, Params);
	
	
	
	this:SetCharacterPlayer(Player)
	this.OnControllerChangedEvent:Connect(function(SAC, HxEnum) 
		if HxEnum ~= Mapping.Enum.CharacterController.PlayerSide then
			this:SetController(Mapping.Enum.CharacterController.PlayerSide)
			Mapping.Exception.CodeException:Throw()
		end
	end)
	return this
end

--[[
	Возвращает привязанного к персонажу игрока.

	@class SadPlayerCharacter
	@side all
	@return Player?
]]
function private:getplr ()
	return private.linked[self]
end

--[[
	Устанавливает игрока для персонажа.

	@class SadPlayerCharacter
	@side all
	@return ()
]]
function private:setplr (Player: Player?)
	private.linked[self] = Player
end

--[[
	Проверяет, является ли переданный игрок привязанным к персонажу.

	@class SadPlayerCharacter
	@side all
	@return boolean
]]
function private:isplr (Player: Player)
	return private.linked[self] == Player
end

class.__index = main.__SadAbstractCharacter.class;
class.ClassName = main.Mapping.Class.SadPlayableCharacter
class.Source = script;

class.GetCharacterPlayer = private.getplr;
class.SetCharacterPlayer = private.setplr;
class.IsCharacterPlayer = private.isplr;
class.OnCharacterPlayerChanged = nil :: HxEvent?;

interface.class = class;
interface.new = private.new;

return main:expand({SadPlayableCharacter = interface})