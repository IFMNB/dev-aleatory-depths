local path = script.Parent.Parent.storage.network
local Sad_Events = table.freeze({
	CoordinateNetwork = path.NCS_CoordinateNetwork, -- NetCoordinateService 
	
	KeyCodeNetwork = path.NIS_KeyCodeNetwork, -- NetInputService
	UserInputNetwork = path.NIS_UserInputNetwork, -- NetInputService
	CameraNetwork = path.NIS_CameraNetwork, -- NetInputService
	
	ContextKeyNetwork = path.GIOMS_ContextKeyNetwork, -- GameIOMappingService (DEPRECATED)
	ContextInputNetwork = path.GIOMS_ContextInputNetwork, -- GameIOMappingService (DEPRECATED)
	
	ContextNetwork = path.ContextNetwork, -- используйтеся любыми сервисами (payload: string, ...: any)
})

return Sad_Events