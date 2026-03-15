local server = require('@game/ServerStorage/server')

local WorldsService = server.Services.WorldsService()

WorldsService.Service:SetActive(true)

local SystemFloor = server.Services.SystemFloor()
local SystemSpawn = server.Services.SystemSpawn()
local SystemFetch = server.Services.SystemFetch()
local SystemRoof = server.Services.SystemRoof()
local SystemScale = server.Services.SystemScale()

SystemRoof.Service:SetActive(true)
SystemFloor.Service:SetActive(true)
SystemFetch.Service:SetActive(true)
SystemScale.Service:SetActive(true)
SystemSpawn.Service:SetActive(true)

SystemRoof.Service:SetDevActive(true)
SystemFloor.Service:SetDevActive(true)