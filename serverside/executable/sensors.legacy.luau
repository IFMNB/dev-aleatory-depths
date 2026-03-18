local server = require('@game/ServerStorage/server')

local WorldsService = server.Services.WorldsService()

WorldsService.Service:SetActive(true)

local SystemFloor = server.Services.System.Sensors.Floor()
local SystemRoof = server.Services.System.Sensors.Roof()
local SystemScale = server.Services.System.Sensors.Scale()

SystemRoof.Service:SetActive(true)
SystemFloor.Service:SetActive(true)
SystemScale.Service:SetActive(true)

SystemRoof.Service:SetDevActive(true)
SystemFloor.Service:SetDevActive(true)