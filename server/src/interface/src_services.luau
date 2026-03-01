local src = setmetatable({}, {__index=require(game.ReplicatedStorage.core).Services})


function src.ConfigService ()
	return require('../service/ConfigService')
end

-- Установщик сетевых владельцев.
function src.NetOwnerService ()
	return require('../service/NetOwnerService')
end

-- Синхронизирует координаты клиента с сервером посредством постоянного стриминга.
function src.NetCoordinateService ()
	return require('../service/NetCoordinateService')
end

-- Общее место хранения карт.
function src.GameMapService ()
	return require('../service/GameMapService')
end

-- Сервис для манипуляций с персонажами, обладающими Humanoid.
function src.GameStunService ()
	return require('../service/NetOwnerService/GameStunService')
end

-- Стандартный низкоуровневый сервис для протокольного доступа к IO данным девайсов клиентов.
function src.NetInputService ()
	return require('../service/NetInputService')
end

--[[
	Сервис более не поддерживается. В Дальнейшем используйте NetIOContextService.
	
	Этот сервис определял зарегистрированные контекстные аналогии и имел как регистрацию глобального контекста,
	так и регистарцию контекста на каждого игрока отдельно. Позволял переопределять клавишы.
]]
@deprecated
function src.GameIOMappingService ()
	return require('../service/NetInputService/GameIOMappingService')
end


return src