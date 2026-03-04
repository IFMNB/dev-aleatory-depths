local Sad_ClassNames = table.freeze({
	
	SadObject = 'SadObject' :: 'SadObject', 
	
		SadMap = 'SadMap' :: 'SadMap',
		SadConfigSnapshot = 'SadConfigSnapshot' :: 'SadConfigSnapshot',
	
		ISadGroup = 'ISadGroup' :: 'ISadGroup',
			SadPhysicGroup = 'SadPhysicGroup' :: 'SadPhysicGroup',
			SadInstanceGroup = 'SadInstanceGroup' :: 'SadInstanceGroup',
	
		SadCharacterReference = 'SadCharacterReference' :: 'SadCharacterReference',
	
		SadAbstractCharacterStats = 'SadAbstractCharacterStats' :: 'SadAbstractCharacterStats',
			SadCharacterProperties = 'SadDefaultCharacterProperties' :: 'SadDefaultCharacterProperties';
	
		SadGameEffect = 'SadGameEffect' :: 'SadGameEffect',
			SadGameEffectProcess = 'SadGameEffectProcess' :: 'SadGameEffectProcess',
	
		SadAbstractAbility = 'SadAbstractAbility' :: 'SadAbstractAbility',
			SadCallbackAbility = 'SadCallbackAbility' :: 'SadCallbackAbility',
			SadInstantAbility = 'SadInstantAbility' :: 'SadInstantAbility',	
	
		SadAbstractCharacter = 'SadAbstractCharacter' :: 'SadAbstractCharacter',
			SadPlayableCharacter = 'SadCharacter' :: 'SadCharacter',
			SadAiCharacter = 'SadAiCharacter' :: 'SadAiCharacter',
	
		SadAbstractService = 'SadAbstractService' :: 'SadAbstractService',
			SadDataService = 'SadDataService' :: 'SadDataService',
			SadGuiService = 'SadGuiService' :: 'SadGuiService',
			SadFXService = 'SadFXService' :: 'SadFXService',
			SadNetService = 'SadNetService' :: 'SadNetService',
			SadGameService = 'SadGameService' :: 'SadGameService',
	
})

return Sad_ClassNames