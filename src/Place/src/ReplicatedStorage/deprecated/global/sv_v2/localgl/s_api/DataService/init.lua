-- https://create.roblox.com/docs/reference/engine/classes/EncodingService looks interesting to use


local gl = require('./')
local hxc = gl.Library.Hexagon.Classes
local int = hxc.Instance()
local evt = hxc.Events()
local cor = gl.Library.CodeBox.Special.Coroutine()
local mt = gl.Library.CodeBox.Tables.Metatables()



local private = {}
private.cl = {}
private.ev = {}

private.evname = 'NetEvent' :: 'NetEvent'
private.ev.dr, private.cl.dr = evt.new(private.evname)
private.ev.ds, private.cl.ds = evt.new(private.evname)
private.cash = mt.SetMode({} :: {[i]: netresult}, 'v')

local service = int.new(private.svc, 'DataService' :: 'DataService')

type nrname = 'NetResult'
type netresult = typeof(int.new({Result=nil::any}, ''::nrname))
type i = string
type w = string | number | boolean | {[w]:w}

-- Read index writen on the DataStore.
function private:Request (To: DataStore, i: i) : netresult
	if private.cash then
		return private.cash[i]
	end
	
	local t0 = {
		Result=nil::any,
		Version = nil :: any -- unused.
	}
	
	local r0 = int.new(t0, 'NetResult'::'NetResult')
	private.cl.dr(To,i)
	service.Reads += 1
	cor.Async(function(OnEnd: () -> (), ...)
		task.defer(function ()
			task.synchronize()
			r0.Result = To:GetAsync(i)
		end)
		r0.Changed:Wait()
		return OnEnd()
	end, function(errmsg: string, DoContinue: () -> (), DoClose: () -> ()) 
		warn(errmsg)
		service.Errors+=1
		task.wait(2)
		r0 = private:Request(To, i)
		return DoContinue()
	end)
	table.freeze(t0)
	
	private.cash[i] = r0
	return r0
end
-- Write data on the DataStore.
function private:Send (To: DataStore, i: i, write: w, GDPR: {any}?)
	private.cl.ds.Call(i,write)
	service.Writes += 1
	cor.Async(function(OnEnd: () -> (), ...) 
		task.synchronize()
		To:SetAsync(i, write, GDPR)
		return OnEnd()
	end, function(errmsg: string, DoContinueCoroutine: () -> (), DoCloseCoroutine: () -> ()) 
		warn(errmsg)
		service.Errors += 1
		task.wait(2)
		private:Send(To, i, write, GDPR)
		return DoContinueCoroutine()
	end)
	return
end

private.svc = {}
private.svc.OnRead = private.ev.dr
private.svc.OnWrite = private.ev.ds
private.svc.Read = private.Request
private.svc.Write = private.Send

private.svc.Reads = 0
private.svc.Writes = 0
private.svc.Errors = 0

return service