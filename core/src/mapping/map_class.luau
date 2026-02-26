local Sad_ClassNames = table.freeze({
	
	SadObject = 'SadObject' :: 'SadObject', -- inherit from HxObject
	--	SadBaseNetwork = 'SadBaseNetwork' :: 'SadBaseNetwork',
	
		
		SadConfigSnapshot = 'SadConfigSnapshot' :: 'SadConfigSnapshot',
		SadMap = 'SadMap' :: 'SadMap',
		SadAbility = 'SadAbility' :: 'SadAbility',
	
		ISadGroup = 'ISadGroup' :: 'ISadGroup',
			SadPhysicGroup = 'SadPhysicGroup' :: 'SadPhysicGroup',
			SadInstanceGroup = 'SadInstanceGroup' :: 'SadInstanceGroup',
	
		ISadCharacter = 'ISadCharacter' :: 'ISadCharacter',
			SadBaseCharacter = 'SadBaseCharacter' :: 'SadBaseCharacter',
				SadCharacter = 'SadCharacter' :: 'SadCharacter',
				SadAiCharacter = 'SadAiCharacter' :: 'SadAiCharacter',
				SadDevCharacter = 'SadDevCharacter' :: 'SadDevCharacter',
		
			ISadCharacterEcsManager = 'ISadCharacterController' :: 'ISadCharacterController',
				SadAbilitiesManager = 'SadAbilitiesManager' :: 'SadAbilitiesManager',
				SadMovementManager = 'SadMovementManager' :: 'SadMovementManager',
	
		SadAbstractService = 'SadAbstractService' :: 'SadAbstractService',
			SadDataService = 'SadDataService' :: 'SadDataService',
			--SadEcsService = 'SadEcsService' :: 'SadEcsService',
			SadGuiService = 'SadGuiService' :: 'SadGuiService',
			SadInputService = 'SadInputService' :: 'SadInputService',
			SadSoundService = 'SadSoundService' :: 'SadSoundService',
			SadNetService = 'SadNetService' :: 'SadNetService',
			SadGameService = 'SadGameService' :: 'SadGameService',
	
})

return Sad_ClassNames