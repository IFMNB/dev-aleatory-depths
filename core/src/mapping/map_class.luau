local Sad_ClassNames = table.freeze({
	
	SadObject = 'SadObject' :: 'SadObject', 
		SadConfigSnapshot = 'SadConfigSnapshot' :: 'SadConfigSnapshot',
	
		SadWorld = 'SadWorld' :: 'SadWorld';
		SadComponentFabric = 'SadComponentFabric' :: 'SadComponentFabric';
	
		SadAbility = 'SadAbstractAbility' :: 'SadAbstractAbility',
		SadEntityFabric = 'SadEntityFabric' :: 'SadEntityFabric',
	
		SadMap = 'SadMap' :: 'SadMap',
	
		ISadGroup = 'ISadGroup' :: 'ISadGroup',
			SadPhysicGroup = 'SadPhysicGroup' :: 'SadPhysicGroup',
			SadInstanceGroup = 'SadInstanceGroup' :: 'SadInstanceGroup',

		SadAbstractService = 'SadAbstractService' :: 'SadAbstractService',
			SadCoreService = 'SadCoreService' :: 'SadCoreService';
			SadDataService = 'SadDataService' :: 'SadDataService',
			SadNetService = 'SadNetService' :: 'SadNetService',
			SadGuiService = 'SadGuiService' :: 'SadGuiService',
			SadFXService = 'SadFXService' :: 'SadFXService',
			SadGameService = 'SadGameService' :: 'SadGameService',
			SadWorldService = 'SadWorldService' :: 'SadWorldService';
			SadService = 'SadService' :: 'SadService';	
})

return Sad_ClassNames