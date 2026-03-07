local Sad_ClassNames = table.freeze({
	
	SadObject = 'SadObject' :: 'SadObject', 
	
		SadWorld = 'SadWorld' :: 'SadWorld';
	
		SadMap = 'SadMap' :: 'SadMap',
		SadConfigSnapshot = 'SadConfigSnapshot' :: 'SadConfigSnapshot',
	
		ISadGroup = 'ISadGroup' :: 'ISadGroup',
			SadPhysicGroup = 'SadPhysicGroup' :: 'SadPhysicGroup',
			SadInstanceGroup = 'SadInstanceGroup' :: 'SadInstanceGroup',
	
	
		SadGameEffect = 'SadGameEffect' :: 'SadGameEffect',
			SadGameEffectProcess = 'SadGameEffectProcess' :: 'SadGameEffectProcess',
	
		SadCharacterReference = 'SadCharacterReference' :: 'SadCharacterReference',
	
		SadAbstractCharacterStats = 'SadAbstractCharacterStats' :: 'SadAbstractCharacterStats',
			SadCharacterProperties = 'SadCharacterProperties' :: 'SadCharacterProperties';
	
		SadAbility = 'SadAbstractAbility' :: 'SadAbstractAbility',

		SadAbstractCharacter = 'SadAbstractCharacter' :: 'SadAbstractCharacter',
			SadPlayableCharacter = 'SadCharacter' :: 'SadCharacter',
			SadScenarioCharacter = 'SadAiCharacter' :: 'SadAiCharacter',
	
		SadCharacterFabric = 'SadCharacterFabric' :: 'SadCharacterFabric',
	
		SadAbstractService = 'SadAbstractService' :: 'SadAbstractService',
			SadDataService = 'SadDataService' :: 'SadDataService',
			SadNetService = 'SadNetService' :: 'SadNetService',
			SadGuiService = 'SadGuiService' :: 'SadGuiService',
			SadFXService = 'SadFXService' :: 'SadFXService',
			SadGameService = 'SadGameService' :: 'SadGameService',
	
})

return Sad_ClassNames