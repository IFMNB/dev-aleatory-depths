local client = require('@game/StarterPlayer/client')

local NetPackageService = client.Services.NetPackageService()
local NetCoordinateService = client.Services.NetCoordinateService()
local NetInputService = client.Services.NetInputService()
local GameIOMappingService = client.Services.GameIOMappingService()
--local GameCameraService = client.Services.GameCameraService()

NetPackageService.Service:SetActive(true)
NetCoordinateService.Service:SetActive(true)
GameIOMappingService.Service:SetActive(true)
GameIOMappingService.Service:SetLogActive(true)
task.wait(1)
GameIOMappingService.Service:SendContextKeyChange('aalf', Enum.UserInputState.Begin, Enum.KeyCode.W)

NetInputService.Service:SetActive(true)
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