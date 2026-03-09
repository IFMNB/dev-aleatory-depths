local src = setmetatable({}, {__index=require(game.ReplicatedStorage.core).Services})


-- Установщик сетевых владельцев.
function src.NetOwnerService ()
	return require('../service/net/NetOwnerService')
end

-- Синхронизирует координаты клиента с сервером посредством постоянного стриминга.
function src.NetCoordinateService ()
	return require('../service/net/NetCoordinateService')
end

-- Общее место хранения карт.
function src.GameMapService ()
	return require('../service/game/GameMapService')
end

-- Сервис для манипуляций с персонажами, обладающими Humanoid.
function src.GameStunService ()
	return require('../service/game/GameStunService')
end

--[[
	Стандартный низкоуровневый сервис для протокольного доступа к IO данным девайсов клиентов.

	@fullAuto false
	@side server
]]
function src.NetInputService ()
	return require('../service/net/NetInputService')
end


return src