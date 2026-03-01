local path = script.Parent.Parent.storage.network
local Sad_Events = table.freeze({
	CoordinateNetwork = path.CoordinateNetwork, -- NetCoordinateService 
	
	KeyCodeNetwork = path.KeyCodeNetwork, -- NetInputService
	UserInputNetwork = path.UserInputNetwork, -- NetInputService
	CameraNetwork = path.CameraNetwork, -- NetInputService
	
	ContextKeyNetwork = path.ContextKeyNetwork, -- GameIOMappingService (DEPRECATED)
	ContextInputNetwork = path.ContextInputNetwork, -- GameIOMappingService (DEPRECATED)
	
	IOContextNetwork = path.IOContextNetwork, -- используется NetIOContextService (payload: string)
})

return Sad_Events