local server = require('@game/ServerStorage/server')

local WorldsService = server.Services.WorldsService()

WorldsService.Service:SetActive(true)

local SystemPosition = server.Services.SystemPosition()
local SystemRotation = server.Services.SystemRotation()
local SystemGravity = server.Services.SystemGravity()
local SystemMass = server.Services.SystemMass()

SystemGravity.Service.UpdateRate = 1/60

SystemPosition.Service:SetActive(true)
SystemRotation.Service:SetActive(true)
SystemGravity.Service:SetActive(true)
SystemMass.Service:SetActive(true)