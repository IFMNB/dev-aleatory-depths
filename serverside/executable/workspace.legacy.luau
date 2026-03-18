local server = require('@game/ServerStorage/server')

local WorldsService = server.Services.WorldsService()

WorldsService.Service:SetActive(true)

local SystemSpawn = server.Services.System.Workspace.Spawn()

SystemSpawn.Service:SetActive(true)