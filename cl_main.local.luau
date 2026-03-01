
local client = require('@game/StarterPlayer/client')

local NetPackageService = client.Services.NetPackageService()
local NetCoordinateService = client.Services.NetCoordinateService()
local NetInputService = client.Services.NetInputService()
local GameContextBusService = client.Services.GameContextBusService()

--local GameIOMappingService = client.Services.GameIOMappingService()
--local GameCameraService = client.Services.GameCameraService()
local NetIOContextService = client.Services.NetIOContextService()
local NetContextGatewayService = client.Services.NetContextGatewayService()

NetPackageService.Service:SetActive(true)
NetPackageService.Service:SetLogActive(true)

NetCoordinateService.Service:SetActive(true)
--GameIOMappingService.Service:SetActive(true)
--GameIOMappingService.Service:SetLogActive(true)
--GameIOMappingService.Service:SendContextKeyChange('aalf', Enum.UserInputState.Begin, Enum.KeyCode.W)

NetContextGatewayService.Service:SetActive(true)
NetContextGatewayService.Service:SetLogActive(true)
NetIOContextService.Service:SetActive(true)
NetIOContextService.Service:SetAuto(true)
NetIOContextService.Service:SetLogActive(true)

GameContextBusService.Service:SetActive(true)
GameContextBusService.Service:SetLogActive(true)




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