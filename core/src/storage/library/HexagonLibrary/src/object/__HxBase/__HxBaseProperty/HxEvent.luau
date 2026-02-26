local main = require('./')

local shadow = require('./HxShade').Shade.new() 

local private = {}
local class = {}; class.__index=main.__HxBaseProperty.class; setmetatable(class,class); class.ClassName=main.ClassNames.HxEvent
local subclass = {}; subclass.__index=main.__HxBaseProperty.class; setmetatable(subclass, subclass);subclass.ClassName=main.ClassNames.HxEventConnection
local subclass2 = {}; subclass2.__index=main.__HxBaseProperty.class; setmetatable(subclass2, subclass2);subclass2.ClassName=main.ClassNames.HxEventProperties
local interface = {}; interface.class = class; interface.subclass = subclass; interface.subclass2 = subclass2

@native
function private.call (event:event, ...: any)
	debug.profilebegin(script.Name..'.call')
	local shade : shade_e = shadow:Get(event)
	
	for i,v in shade._c do
		local shade_c : shade_c = shadow:Get(v)
		local parallel : boolean = shade_c._t == 'ParallelOnce' or shade_c._t == 'ParallelConnection'
		local once : boolean = shade_c._t == 'Once' or shade_c._t == 'ParallelOnce'
		
		local thread : thread
		
		if once then
			v:Disconnect()
		end
		
		if parallel then
			task.spawn(function(...) 
				task.desynchronize()
				shade_c._f(...)
			end, ...)
		else
			task.spawn(function(...) 
				shade_c._f(...)
			end, ...)
		end
	end
	debug.profileend()
end

type p0 = typeof(class)
type p1 = typeof(subclass)
type obj_t = typeof(main.new({},main.__HxBaseProperty.class))

type function ev_name_v3 (a0: type, r0tempname: type)
	local types = types
	
	local r0 : type
	
	if a0:is('unknown') then
		r0 = r0tempname
	elseif a0:is('string') then
		r0 = types.string
	else
		r0 = a0
	end
	
	return r0
end

-- Constructors



type event = typeof(private.new_event(nil))
-- Creates an event and his property object.
@native
function private.new_event <t0, t1> (EventName: t0?)
	debug.profilebegin(script.Name..'.new_event')	
	
	if EventName then
		assert(type(EventName)=='string', 'EventName must be a string')
	end
	
	local signal = main.new({Name=EventName :: t0 },class)
	local shade = private.new_shade_event(signal)
	local raw = {}
	raw.Name = EventName :: t0

	function raw.Call (...: any)
		private.call(signal,...)
	end
	
	function raw:Remove ()
		for i,v in shade._c do
			v:Disconnect()
		end
	end
	

	function raw:Destroy ()
		raw:Remove()
		table.freeze(shade._c)
	end


	function raw:GetCount ()
		return #shade._c
	end
	

	function raw:Clear (target: cons)
		for i,v in shade._c do
			local shade_con : shade_c = shadow:Get(v)
			if shade_con._t == target then
				v:Disconnect()
			end
		end
	end
	
	-- By this object you can control event
	local property = main.new(raw,subclass2)
	
	debug.profileend()
	return signal, property
end

type shade_e = typeof(private.new_shade_event({}::any))
function private.new_shade_event <t0> (event: event)
	type shade = {
		_c: {conn},
	}

	local shade : shade = shadow:Get(event)
	shade._c = {}

	return shade
end

type cons = 'Connection'|'Once'|'ParallelConnection'|'ParallelOnce'
type conn = typeof(private.new_conn(nil::any,nil::any,nil::any))
function private.new_conn (event: event, f: (...any)->any,t: cons)
	debug.profilebegin(script.Name..'.new_conn')
	
	local conn = main.new({Connected=true},subclass)
	local shade_e : shade_e = shadow:Get(event)
	local shade_c : shade_c = private.new_shade_conn(conn,f,t,event)
	
	table.insert(shade_e._c, conn)
	
	debug.profileend()
	return conn
end

type shade_c = typeof(private.new_shade_conn({}::conn, nil::any, nil::any,nil::any))
function private.new_shade_conn (conn: conn, f: any, t: any, par: event, relativekey: any)
	type shade = {
		_f: (...any)->(),
		_t: cons,
		_p: event,
		_r: any
	}
	
	local shade : shade = shadow:Get(conn)
	shade._f=f;
	shade._t=t;
	shade._p=par;
	shade._r=relativekey;
	
	return shade
end

-- Yields the current thread until the signal fires and returns the arguments provided by the signal.
function private:yield ()
	local event = self :: event
	local thread = coroutine.running()
	event:Once(function(...) coroutine.resume(thread, ...) end)
	
	return coroutine.yield()
end


-- Event Methods

-- Connects the given function to the event and returns an HxConnection that represents it.
function private:connect (f: (...any)->())
	return private.new_conn(self::event,f,'Connection')
end
-- Connects the given function to the event (for a single invocation) and returns an HxConnection that represents it. 
function private:once (f: (...any)->())
	return private.new_conn(self::event,f,'Once')
end
-- Connects the given function to the event and returns an HxConnection that represents it. Executes inside parallel runcontext.
function private:parcon (f: (...any)->())
	return private.new_conn(self::event, f, 'ParallelConnection')
end
-- Connects the given function to the event (for a single invocation) and returns an HxConnection that represents it. Executes inside parallel runcontext.
function private:paronce (f: (...any)->())
	return private.new_conn(self::event, f, 'ParallelOnce')
end


-- Connection Methods

-- Disconnects the connection from the event.
function private:disconnect ()
	debug.profilebegin(script.Name..':disconnect')
	
	local conn = self :: conn
	local shade_c : shade_c = shadow:Get(conn);
	local shade_p : shade_e = shadow:Get(shade_c._p);
	conn.Connected=false;
	table.remove(shade_p._c, table.find(shade_p._c,conn));
	
	debug.profileend()
	return
end

class.Name = class.ClassName
class.OnceParallel = private.paronce
class.ConnectParallel = private.parcon
class.Connect = private.connect
class.Wait = private.yield
class.Once = private.once
class.Source=script

subclass.Disconnect = private.disconnect
subclass.Source=script

subclass2.Source=script
subclass2.Call = (nil::any) :: (...any) -> ()
subclass2.Destroy = (nil::any) :: () -> ()
subclass2.Remove = (nil::any) :: (target: cons) -> ()
subclass2.GetCount = (nil::any) :: () -> number
subclass2.Clear = (nil::any) :: () -> ()
subclass2.Name = class.Name

interface.new = private.new_event

table.freeze(private)
table.freeze(class)
table.freeze(subclass2)
table.freeze(subclass)
table.freeze(interface)
return main:expand({Events=interface})