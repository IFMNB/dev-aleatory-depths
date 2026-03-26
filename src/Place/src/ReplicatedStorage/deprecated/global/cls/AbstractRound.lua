local gl = require('./')

local hxc = gl.Library.Hexagon.Classes
local ob = hxc.Object()
local ev = hxc.Events()
local sh = gl.Library.CodeBox.Tables.Shadow()

local private = {}
local public = {}
local class = {}

public.OnCreatedEvent, private.ev0 = ev.new('ConstructEvent' :: 'ConstructEvent')


type Round = typeof(private.new({}::RoundData<any>))
type EventProperties = typeof(private.ev0)
type RoundData <Map> = {
	PlayerPackage: {
		Players: {Player},
		Murders: {Player}
	},
	GamePackage: {
		Map: Map,
		Spawns: {Vector3},
	}
}
type shade = {
	_start: EventProperties,
	_end: EventProperties,
	_exit: EventProperties,
	_kill: EventProperties,
	_leave: EventProperties
}

private.ev_name = 'RoundEvent' :: 'RoundEvent'

-- Creates abstract Round object.
function private.new <Map> (RoundData: RoundData <Map>)
	local element = table.clone(public)
	local round = ob.New(element)
	local shade : shade = sh.New(round)
	
	element.Round = RoundData
	element.OnStartEvent, shade._start = ev.new(private.ev_name)
	element.OnExitEvent, shade._exit = ev.new(private.ev_name)
	element.OnEndEvent, shade._end = ev.new(private.ev_name)
	element.OnPlayerKillEvent, shade._kill = ev.new(private.ev_name)
	element.OnPlayerLeaveEvent, shade._leave = ev.new(private.ev_name)
	
	return round
end

function private:KillPlayer ()
	local shade : shade = sh.Get(self)

end


class.new = private.new
return class