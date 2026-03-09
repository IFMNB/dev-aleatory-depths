local interface = setmetatable({}, {__index=require('@self/src_libs')})

--[[
	Получает карту, определенную для данного сервиса.
	
	@raw
]]
function interface:GetServiceMapping ()
	return require('./mapping')
end


--[[
	Низкоуровневый сетевой сервис, предназначенный для протоколированной сериализации
	и передачи информации по сети с очень ужатыми размерами.

	Данный сервис используется всеми сетевыми сервисами.

	@fullAuto false
	@side all
]]
function interface.NetPackageService ()
	return require('./service/NetPackageService')
end

--[[
	Сервис для более удобного управления группами коллизий, представляя их как объекты.
	
	Доступен на клиенте по причине локального мира.
	
	@fullAuto false
	@side all
]]
function interface.GameCollisionService ()
	return require('./service/GameCollisionService')
end

--[[
	Сервис для распознавания и обработки попаданий хитбоксов по моделям и игрокам.
	
	Доступен на клиенте по причине локального мира.
	
	@fullAuto false
	@side all

]]
function interface.GameHitScanService ()
	return require('./service/GameCollisionService/GameHitScanService')
end

--[[
	Сервис для обработки глобальных ивентов внутри игры.
	
	Несмотря на то, что данный сервис по сути представляет глобальное поведение,
	что может быть неявным при неправильном использовании, данный сервис
	должен использоваться при помощи константных неизменных переменных, которые
	будут направлять всех пользователей сервиса в правильные позиции.
	
	@fullAuto false
	@side all
]]
function interface.GameContextBusService ()
	return require('./service/GameContextBusService')
end

--[[
	Сервис-ворота для единой точки доступа ко всему контекстному нетворку.

	@fullAuto false
	@side all
]]
function interface.NetContextGatewayService ()
	return require('./service/NetPackageService/NetContextGatewayService')
end

--[[
	Сервис для единой точки доступа к существующим мирам в текущем конкретном потоке.

	@fullAuto false
	@side all
]]
function interface.GameWorldsService ()
	return require('./service/GameWorldsService')
end

return interface