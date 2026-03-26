local gl = require('../')

local instance = gl.Library.Hexagon.Classes.Instance()
local event = script.RemoteEvent

type Info = any

local private = {}
local service

private.plr = game.Players.LocalPlayer :: Player
private.service = {}
service = instance.New(private.service, 'ClientNetworkService' :: 'ClientNetworkService')

event.OnClientEvent:Connect(function(info: Info, ...: any) 
	local get = {...}
	
	warn('event')
	
	if info == 'CharacterChange' then
		local chr = private.plr.Character
		if chr then
			local root = chr.PrimaryPart
			if root then
				root.CFrame = get[1]
			end
		end
		
		(service::any).CharacterOwner = 'Server'
		
		
	elseif info == 'PartCFrameChange' then
		local part = get[1] :: BasePart
		part.CFrame = get[2]
	
	elseif info == 'CharacterChangeOver' then
		(service::any).CharacterOwner = 'Client'
	end
end)

private.service.CharacterOwner = 'Client' :: 'Client' | 'Server'

return service