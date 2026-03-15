local server = require('@game/ServerStorage/server')

local WorldsService = server.Services.WorldsService()

WorldsService.Service:SetActive(true)

local SystemPosition = server.Services.SystemPosition()
local SystemRotation = server.Services.SystemRotation()

SystemPosition.Service:SetActive(true)
SystemRotation.Service:SetActive(true)

SystemPosition.Service:SetDevActive(true)