local server = require('@game/ServerStorage/server')

local WorldsService = server.Services.WorldsService()

WorldsService.Service:SetActive(true)

local SystemPosition = server.Services.SystemPosition()
local SystemRotation = server.Services.SystemRotation()
local SystemSurface = server.Services.SystemSurface()
local SystemSpawner = server.Services.SystemSpawner()

SystemSpawner.Service:SetActive(true)
SystemSpawner.Service:SetLogActive(true)
SystemPosition.Service:SetActive(true)
SystemRotation.Service:SetActive(true)
SystemSurface.Service:SetActive(true)