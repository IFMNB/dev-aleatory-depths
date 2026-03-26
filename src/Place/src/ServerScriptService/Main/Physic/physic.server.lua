local server = require('@game/ServerStorage/server')

local WorldsService = server.Services.WorldsService()

WorldsService.Service:SetActive(true)

local SystemPosition = server.Services.System.Physic.Position()
local SystemRotation = server.Services.System.Physic.Rotation()
local SystemGravity = server.Services.System.Physic.Gravity()

local SystemVelocity = server.Services.System.Physic.Velocity()

SystemVelocity.Service.UpdateRate = 1/60
SystemGravity.Service.UpdateRate = 1/60
SystemRotation.Service.UpdateRate = 1/60

SystemPosition.Service:SetActive(true)
SystemRotation.Service:SetActive(true)
SystemGravity.Service:SetActive(true)
SystemVelocity.Service:SetActive(true)