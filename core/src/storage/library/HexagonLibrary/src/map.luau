local ClassNames_Hexagon_Map = {	
	HxObject = 'HxObject'::'HxObject',
		HxRuntimeException = 'HxRuntimeException'::'HxRuntimeException',
		HxLocalEnum = 'HxLocalEnum'::'HxLocalEnum',
	
		
		HxBase = 'HxBase'::'HxBase',
	
			HxBaseProperty = 'HxBaseProperty'::'HxBaseProperty', 
				HxSnapshot = 'HxSnapshot'::'HxSnapshot',
				HxShade = 'HxShade'::'HxShade',
	
				HxAbstractMetalink = 'HxAbstractMetalink'::'HxAbstractMetalink',
					HxMetalinkCreator = 'HxMetalinkNew'::'HxMetalinkNew',
	
				HxHooker = 'HxHooker'::'HxHooker',
				HxActionEmmiter = 'HxActionEmmiter',
	

	
				HxEvent = 'HxEvent'::'HxEvent',
					HxEventConnection = 'HxEventConnection'::'HxEventConnection',
					HxEventProperties = 'HxEventProperties'::'HxEventProperties',
	
			HxAbstractPrimetive = 'HxAbstractPrimetive'::'HxAbstractPrimetive',
				HxString = 'HxString'::'HxString',
					HxTranslationString = 'HxTranslationString'::'HxTranslationString',
	
				HxNumber = 'HxNumber'::'HxNumber',
					HxNumberModifier = 'HxNumberModifier'::'HxNumberModifier',
	
				HxBaseCollection = 'HxBaseCollection'::'HxBaseCollection',
					HxNode = 'HxNode'::'HxNode',
						HxNodeList = 'HxList'::'HxList',
	
					IHxList = 'IHxList'::'IHxList',
						HxList = 'HxList'::'HxList',
						HxWeakList = 'HxWeakList'::'HxWeakList',
	
					IHxMap = 'IHxMap'::'IHxMap',
						HxMap = 'HxMap'::'HxMap',
						HxWeakMap = 'HxWeakMap'::'HxWeakMap',
	
	
	
			HxInstance = 'HxInstance'::'HxInstance',
				HxInstanceProperties = 'HxInstanceProperties'::'HxInstanceProperties',
				
	
				HxAbstractDataTree = 'HxAbstractDataTree'::'HxAbstractDataTree', -- Auto-Replicatable.
					HxWorldStorage = 'HxWorldStorage'::'HxWorldStorage',
	
				HxBaseParallel = 'HxBaseParallel'::'HxBaseParallel', 
					HxParallelWorker = 'HxParallelWorker'::'HxParallelWorker',
					HxParallelConstantWorker = 'HxParallelConstantWorker'::'HxParallelConstantWorker',

		EcsBase = 'EcsBase' :: 'EcsBase',
			EcsComponent = 'EcsComponent'::'EcsComponent',
	
			EcsEntity = 'EcsEntity'::'EcsEntity',
	
			EcsBaseSystem = 'EcsBaseSystem'::'EcsBaseSystem',
				EcsSystem = 'EcsSystem'::'EcsSystem', 
				EcsSystemIO = 'EcsSystemIO'::'EcsSystemIO',
	
			EcsWorld = 'EcsWorld'::'EcsWorld',
				
}
return table.freeze(ClassNames_Hexagon_Map)