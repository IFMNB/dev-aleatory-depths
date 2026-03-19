local server = require(game.ServerStorage.server)

local NetworkService = server.Services.NetworkService()
local NetOwnerService = server.Services.Net.OwnerService()
local NetCoordinateService = server.Services.Net.CoordinateService()
local NetInputService = server.Services.Net.IOService()
local ContextGateway = server.Services.ContextGateway()

local GameMapService = server.Services.Game.MapService()
local GameStunService = server.Services.Game.StunService()
local CollisionService = server.Services.CollisionService()
local HitScanService = server.Services.HitScanService()
local ContextBus = server.Services.ContextBus()
local WorldsService = server.Services.WorldsService()

GameMapService.Service:SetActive(true)
GameStunService.Service:SetActive(true)
CollisionService.Service:SetActive(true)
HitScanService.Service:SetActive(true)
HitScanService.Service:SetLogActive(true)
ContextBus.Service:SetActive(true)
ContextBus.Service:SetLogActive(true)
WorldsService.Service:SetActive(true)
WorldsService.Service:SetLogActive(true)

NetworkService.Service:SetActive(true)
NetworkService.Service:SetLogActive()
NetOwnerService.Service:SetAuto(true)
NetOwnerService.Service:SetActive(true)
NetCoordinateService.Service:SetActive(true)
NetCoordinateService.Service:SetAuto(true)
NetInputService.Service:SetActive(true)
NetInputService.Service:SetAuto(true)
NetInputService.Service:SetLogActive(true)
ContextGateway.Service:SetActive(true)
ContextGateway.Service:SetLogActive(true)

local TestZone = GameMapService.Service:GetMap('TestZone')
TestZone:MapLoad() 




--SystemPosition.Service:SetLogActive(true)

local world = WorldsService.Service:GetWorld('game.world')
local Fortuna = server.Characters.Fortuna()

for i=1, 1 do
	local fortuna_w = world:AddWorldNew()
	world:DoCallForCatchedWorld(fortuna_w, function(World) 
		Fortuna:DoUnpackTo(World)
	end)
end

print(world)