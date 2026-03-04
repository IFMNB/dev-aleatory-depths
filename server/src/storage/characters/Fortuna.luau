local main = require('../../')

local SadObject = main.Core.Classes.SadObject();
local SadCharacterProperties = require('../classes/__SadAbstractCharacterStats/SadCharacterProperties').SadCharacterProperties
local SadPlayeableCharacter = require('../classes/__SadAbstractCharacter/SadPlayeableCharacter').SadPlayableCharacter

local private = {}

local FortunaTemplate = table.freeze(SadObject.new({
	CharacterModel = script.Fortuna;
	CharacterProperties = table.freeze(SadCharacterProperties.new(100, 24, 1, 1));
	CharacterAbilities = table.freeze({
		
	})
	Create = function (Player: Player?)
		return SadPlayeableCharacter.new()
	end,
}))

return FortunaTemplate