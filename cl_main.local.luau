
local client = require('@game/StarterPlayer/client')

local NetworkService = client.Services.NetworkService()
local NetCoordinateService = client.Services.NetCoordinateService()
local NetInputService = client.Services.NetInputService()
local ContextBus = client.Services.ContextBus()

--local GameIOMappingService = client.Services.GameIOMappingService()
--local GameCameraService = client.Services.GameCameraService()
local NetIOContextService = client.Services.NetIOContextService()
local ContextGateway = client.Services.ContextGateway()

NetworkService.Service:SetActive(true)
NetworkService.Service:SetLogActive()

NetCoordinateService.Service:SetActive(true)
--GameIOMappingService.Service:SetActive(true)
--GameIOMappingService.Service:SetLogActive(true)
--GameIOMappingService.Service:SendContextKeyChange('aalf', Enum.UserInputState.Begin, Enum.KeyCode.W)

ContextGateway.Service:SetActive(true)
ContextGateway.Service:SetLogActive()
NetIOContextService.Service:SetActive(true)
NetIOContextService.Service:SetAuto(true)
NetIOContextService.Service:SetLogActive(true)

ContextBus.Service:SetActive(true)
ContextBus.Service:SetLogActive(true)




NetInputService.Service:SetActive(false)
NetInputService.Service:SetAuto(true)


--GameCameraService.Service:SetActive(true)
--GameCameraService.Service:SetAuto(true)
--GameCameraService.Service:Move(Vector3.new(0, 0, -4500))
--GameCameraService.Service:ChangeFov(100, 2)
--GameCameraService.Service:MoveTo(Vector3.new(3,52,1))
--GameCameraService.Service:Rotate(Vector3.new(365))
--GameCameraService.Service:SetLogActive(true)

--client.Services.NetPackageService().Service:SetLogActive(true)
--client.Services.NetCoordinateService().Service:SetLogActive(true) 