local gl = require('./')
local instance = gl.Library.Hexagon.Classes.Instance()

type ClientCfgResult = typeof(gl._types.ClientCfgResult)
type ClientGlobalReplicator = typeof(gl._types.ClientGlobalReplicator)

local event = script.RemoteEvent
local func = script.RemoteFunction

local private = {}
local service

private.service = {}
private.service.ReplicatedConfig = (nil::any) :: ClientCfgResult
private.service.ReplicatedRound = (nil::any) :: any?
service = instance.New(private.service, 'ClientConfigService' :: 'ClientConfigService')

type infotypes = typeof(({}::ClientGlobalReplicator)._typecheck.InfoTypes)

event.OnClientEvent:Connect(function(Info: infotypes, replicated: any)
	if Info == 'Config' then
		private.service.ReplicatedConfig = replicated
	elseif Info == 'Round' then
		private.service.ReplicatedRound = replicated
	end
end)
event:FireServer('All')

-- Update information from server.
function private:Update (Info: infotypes)
	if Info == 'Config' then
		(service::any).ReplicatedConfig = func:InvokeServer(Info);
	elseif Info == 'Round' then
		(service::any).ReplicatedRound = func:InvokeServer(Info);
	elseif Info == 'All' then
		(service::any).ReplicatedConfig = func:InvokeServer(Info);
		(service::any).ReplicatedRound = func:InvokeServer(Info);
	end	
end

-- Asyncronously update information from server.
function private:UpdateAsync (Info: infotypes)
	event:FireServer(Info)
end

private.service.UpdateAsync = private.UpdateAsync

return service