local interface = setmetatable({}, {__index=require('@self/src_libs')})

function interface:GetServiceMapping ()
	return require('./mapping')
end


function interface.NetPackageService ()
	return require('./service/NetPackageService')
end

function interface.GameCollisionService ()
	return require('./service/GameCollisionService')
end

function interface.GameHitScanService ()
	return require('./service/GameCollisionService/GameHitScanService')
end

function interface.GameContextBusService ()
	return require('./service/GameContextBusService')
end 

return interface