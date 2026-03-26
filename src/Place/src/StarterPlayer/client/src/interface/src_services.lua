local src = setmetatable({}, {__index=require(game.ReplicatedStorage.core).Services})


--[[
	Низкоуровневый сервис синхронизации, предназначенный для контроля координат персонажа игрока.
	
	В случае начала трансляции сервера, клиент автоматически подхватывает трансляцию и начинает
	проецирование координат на локальную версию персонажа.

	@fullAuto true
	@side client
]]
function src.NetCoordinateService ()
	return require('../service/NetCoordinateService')
end

--[[
	Стандартный низкоуровневый сервис для протокольного доступа к IO данным девайсов клиента.

	На самом клиенте представляет способ отправки сырых IO данных на сервер.

	@fullAuto false
	@side client
]]
function src.NetInputService ()
	return require('../service/NetInputService')
end

--[[
	Ключевой низкоуровневый сервис для управления камерой. Обладает всем, что может быть связано с камерой.
	
	Этот сервис используется везде и отовсюду и представляет из себя скомпанованный сервис с подконтрольной
	автоматизацией или ручным вводом. Все дальнейшие операции с камерой при активации этого сервиса
	выполняются строго через него, хотя сервис и не выйдет из строя при его игнорировании.
	
	@fullAuto false
	@side client
]]
function src.GameCameraService ()
	return require('../service/GameCameraService')
end

--[[
	Сервис более не поддерживается. В Дальнейшем используйте NetIOContextService.
	
	Этот сервис определял зарегистрированные контекстные аналогии и имел как регистрацию глобального контекста,
	так и регистарцию контекста на каждого игрока отдельно. Позволял переопределять клавишы.
	
	@fullAuto true
	@side client
]]
@deprecated
function src.GameIOMappingService ()
	return require('../service/GameIOMappingService')
end

--[[
	Сервис для упрощенной передачи IO контекстов для вызова разнообразных операций на сервере.
	
	Этот сервис не позволит переопределить заранее созданные IO-контексты, однако дает возможность переопределить
	способы вызова того или иного контекста. По сути, этот сервис является сервисом действий клиента на сервере.
	
	@fullAuto false
	@side client
]]
function src.NetIOContextService ()
	return require('../service/NetIOContextService')
end

return src