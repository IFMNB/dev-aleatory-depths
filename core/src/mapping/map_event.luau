local path = script.Parent.Parent.storage.network
local Sad_Events = table.freeze({
	ConfigNetwork = path.ConfigNetwork,
	
	RoundNetwork = path.RoundNetwork,
	
	CoordinateNetwork = path.CoordinateNetwork,
	
	KeyCodeNetwork = path.KeyCodeNetwork,
	UserInputNetwork = path.UserInputNetwork,
	CameraNetwork = path.CameraNetwork,
	
	ContextKeyNetwork = path.ContextKeyNetwork,
	ContextInputNetwork = path.ContextInputNetwork,
})

return Sad_Events