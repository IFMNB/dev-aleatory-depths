local src = setmetatable({}, {__index=require(game.ReplicatedStorage.core).Services})

function src.NetCoordinateService ()
	return require('../service/NetCoordinateService')
end

function src.NetInputService ()
	return require('../service/NetInputService')
end

function src.GameCameraService ()
	return require('../service/GameCameraService')
end

function src.GameIOMappingService ()
	return require('../service/GameIOMappingService')
end

return src