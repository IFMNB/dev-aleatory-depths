local main = require('./')
local event = main.I_Base.Classes.HxEvent()

local private = {};
local class = {};
class.__index=main.__EcsBaseSystem.class;
setmetatable(class,class);
local interface = {}

type EcsEntity = typeof(main.EcsEntity.new())
type EcsSystemIO = typeof(interface.new())
export type IOSystemCall = (EcsSystemIO: EcsSystemIO, InputEventProperties: typeof(private.event), OutputEventProperties: typeof(private.event), EcsEntity: EcsEntity) -> ()

function private.new <Dependencies> (SystemCall: IOSystemCall?,Dependencies: Dependencies?)
	local input, iproperties = event.new(private.eventname)
	local output, oproperties = event.new(private.eventname)
	local SystemCall = SystemCall or warn :: IOSystemCall;
	local this : any
	local function Outline (HxSystem: EcsSystemIO, EcsEntity: EcsEntity) return SystemCall(this, iproperties, oproperties, EcsEntity) end
	this = main.new({
		SystemCall = Outline,
		Dependencies = Dependencies :: Dependencies,
		OnInputEvent = input,
		OnOutputEvent = output,
		SystemId = tostring(tick())
	}, class)
	return this
end

private.eventname = 'IOEvent'::'IOEvent';
class.OnInputEvent, private.event = event.new(private.eventname); private.event:Destroy()
class.OnOutputEvent = class.OnInputEvent; 
class.ClassName=main.ClassNames.EcsSystemIO;
class.Source=script


interface.class = class;
interface.new = private.new;


table.freeze(class)
table.freeze(interface)
table.freeze(private)

return main:expand({EcsSystemIO = interface})