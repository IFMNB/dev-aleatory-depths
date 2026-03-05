local main = require('../../');

local private = {};
local class = {};
local interface = {};

--local SadCharacterReference = require('./SadCharacterReference').SadCharacterReference;
--local SadAbility = require('./SadAbility').SadAbility;
local SadCharacterProperties = require('./__SadAbstractCharacterStats/SadCharacterProperties').SadCharacterProperties;

local SadPlayableCharacter = require('./__SadAbstractCharacter/SadPlayeableCharacter').SadPlayableCharacter;

type SadCharacterFabric <MD0=Model, P0=SadCharacterProperties> = typeof(interface.new(nil::MD0,nil::P0));
type SadCharacterReference <MD=Model> = typeof(require('./SadCharacterReference').SadCharacterReference.new(nil::MD))
type SadCharacterProperties = typeof(require('./__SadAbstractCharacterStats/SadCharacterProperties').SadCharacterProperties.new())
type SadAbility = typeof(require('./SadAbility').SadAbility.new())
type Controllers = index<typeof(class.Enums), keyof<typeof(class.Enums)>>

function private.new (Properties: SadCharacterProperties, Model: Model?, ...: SadAbility)
	local this = main.new({
		CharacterModel = Model;
		CharacterProperties = Properties;
		CharacterAbilities = {...}
	}, class)
	
	return this
end


--[[
	Создает экземпляр персонажа исходя из собственной ткани.
	
	Пока что все персонажи - игроки, но в будущем могут появится и NPC
	
	@class SadCharacterFabric
	@side all
	@return Instance (@P SadPlayeableCharacter)
]]
function private:create_character_instance (ControllerType: Controllers, Player: Player?)
	local self = self :: SadCharacterFabric;
	
	if ControllerType == class.Enums.PlayerSide then
		return SadPlayableCharacter.new(self.CharacterProperties, self.CharacterModel, Player)
	elseif ControllerType == class.Enums.AiSide then
		return main.Mapping.Exception.TechicalException:Throw()
	elseif ControllerType == class.Enums.ScenarioSide then
		return main.Mapping.Exception.TechicalException:Throw()
	else
		return main.Mapping.Exception.TechicalException:Throw()
	end
end

class.__index = main.Core.Classes.SadObject().class;
class.ClassName = main.Mapping.Class.SadCharacterFabric;
class.Source = script;
class.Enums = main.Mapping.Enum.CharacterController
class.CharacterModel = script.Parent.Parent.models.err_mdl:Clone();
class.CharacterProperties = table.freeze(SadCharacterProperties.new());
class.Create = private.create_character_instance;

interface.class = class;
interface.new = private.new;

return main:expand({SadCharacterFabric = interface})