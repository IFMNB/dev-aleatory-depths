local main = require('../../')

local SadCharacterProperties = require('../classes/__SadAbstractCharacterStats/SadCharacterProperties').SadCharacterProperties
local SadAbility = require('../classes/SadAbility').SadAbility
local SadCharacterFabric = require('../classes/SadCharacterFabric').SadCharacterFabric

local Fortuna = SadCharacterFabric.new(SadCharacterProperties.new(
	100, 20, 1, 0.8	
	), script.Parent.Parent.models.characters.Fortuna,
	SadAbility.new()
)

return Fortuna