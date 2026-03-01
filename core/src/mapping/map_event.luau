local path = script.Parent.Parent.storage.network
local Sad_Events = table.freeze({
	CoordinateNetwork = path.CoordinateNetwork, -- NetCoordinateService 
	
	KeyCodeNetwork = path.KeyCodeNetwork, -- NetInputService
	UserInputNetwork = path.UserInputNetwork, -- NetInputService
	CameraNetwork = path.CameraNetwork, -- NetInputService
	
	ContextKeyNetwork = path.GIOMS_ContextKeyNetwork, -- GameIOMappingService (DEPRECATED)
	ContextInputNetwork = path.GIOMS_ContextInputNetwork, -- GameIOMappingService (DEPRECATED)
	
	IOContextNetwork = path.IOContextNetwork, -- используется NetIOContextService (payload: string)
	ContextNetwork = path.ContextNetwork, -- используйтеся любыми сервисами (payload: string, ...: any)
})

return Sad_Events