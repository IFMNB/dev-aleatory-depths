local gl = require('../')
local hxc = gl.Library.Hexagon.Classes

local int = hxc.Instance()
local ev = hxc.Events()
local cor = gl.Library.CodeBox.Special.Coroutine()

local REPLICA = gl.Library.AllPath.Replicate
local ConfigService = require('../ConfigService')
local DataService = require('../DataService')

local private = {}
private.cl = {}
private.svc = {}

private.infr = ConfigService:Get('Game').Inform

private.ev_name = 'ReplicatorEvent' :: 'ReplicatorEvent'
private.svc.OnConfigRequestEvent, private.cl.OnConfigRequestEvent = ev.new(private.ev_name)
private.svc.OnGameDataRequestEvent, private.cl.OnGameDataRequestEvent = ev.new(private.ev_name) 
private.svc.OnCurrentGameStateRequestEvent, private.cl.OnCurrentGameStateRequestEvent = ev.new(private.ev_name)
private.svc.OnErrorRequestEvent, private.cl.OnErrorRequestEvent = ev.new(private.ev_name)
private.svc.OnCharacterDataRequestEvent, private.cl.OnCharacterDataRequestEvent = ev.new(private.ev_name)
private.svc.UseParallel = false

REPLICA.CDR.OnServerInvoke = function (player: Player, RQ: 'MyData' | 'Client') : any
	local r0
	
	cor.AsyncWait(function(OnEnd: () -> (), ...) 
		if RQ == 'MyData' then
			
		end
	end, function(errmsg: string, DoContinueCoroutine: () -> (), DoCloseCoroutine: () -> ()) 
		warn(errmsg)
		private.cl.OnErrorRequestEvent(player,RQ)
		return DoCloseCoroutine()
	end)
	
	return r0
end

-- RemoteFunction used to getting the Characters target data.
REPLICA.CDR.TAR.OnServerInvoke = function (player: Player, RQ: keyof<typeof(ConfigService:Get('Game').Inform)>) : any
	local r0
	cor.AsyncWait(function(OnEnd: () -> (), ...) 
		r0 = assert((private.infr::any)[RQ],'No config data block.')
		if RQ == 'Defined' then error('ServerCore.') end
		return OnEnd()
	end, function(errmsg: string, DoContinueCoroutine: () -> (), DoCloseCoroutine: () -> ()) 
		warn(errmsg)
		private.cl.OnErrorRequestEvent(player, RQ)
		return DoCloseCoroutine()
	end)
	return r0
end

local replicator = int.New(private.svc, 'ClientDataReplicator'::'ClientDataReplicator')

return replicator