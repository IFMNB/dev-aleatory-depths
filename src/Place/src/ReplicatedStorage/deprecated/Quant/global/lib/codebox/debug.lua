--!strict

local HttpService = game:GetService('HttpService')
local Debris = game:GetService('Debris')

local private = {}
local plugin = {}

local tmw = 0.5

do
	if not game["Run Service"]:IsStudio() then 
		return setmetatable({}, {__index = function ()
			return function () warn('cancel d-api') end
		end,}) :: self
	end
end



local dbg = Instance.new('Folder')
dbg.Parent = workspace
dbg.Name = 'debug'

private.nontbl = 'non-table' :: 'non-table'
private.lifetime = setmetatable({} :: {[{}]: number}, {__mode = 'k'})
private.lifeid =  setmetatable({} :: {[string]: {}}, {__mode = 'v'})

function private.DoCountElement (self: {}) : string
	local tp = type(self)
	
	if tp == 'table' then
		local c = 0
		for i,v in pairs(self :: any) do
			c += 1
		end
		
		return string.format('#%s, %q', tostring(#self), tostring(c))
	else
		return private.nontbl
	end
end

function private.DoStoreTableById (self: {}) : string
	local id = game.HttpService:GenerateGUID(false)
	
	private.lifeid[id] = self
	return id
end

function private.DoAddLifetime (self: {})
	private.lifetime[self]= private.lifetime[self] ~= nil and private.lifetime[self] + tmw or 0
end

function private.DoGetLifetime (self: {}) : number
	return private.lifetime[self]
end

function private.DoGetTableById (self:string) : {}
	return private.lifeid[self]
end

function private.DoGetData (self: {})
	return private.DoStoreTableById(self), tostring(self)
end

function private.DoLogInformation (id: string, ss: string)
	local cor : thread
	cor = coroutine.create(function ()
		debug.setmemorycategory(id)
		while task.wait(tmw) do
			local this = private.DoGetTableById(id)
			local lftm = private.DoGetLifetime(this)
			local exists = not not this
			local elm = private.DoCountElement(this)
			
			print(string.format('Translation for %q', ss), {
				elements = elm,
				id = id,
				translationLifetime = lftm,
				string = ss,
				table = this,
				exists = exists,
				mem = debug.getmemorycategory()
			})
			
			if not exists then break else private.DoAddLifetime(this) end
		end
		warn(string.format('Translation end for table %q', ss))
		debug.resetmemorycategory()
	end)
	
	coroutine.resume(cor)
	
	return cor
end

function private.DoRoot (self: {})
	return private.DoLogInformation(private.DoGetData(self))
end

function private.DoSpectateAtCoroutine (self: thread)
	return task.spawn(function()
		warn(string.format('Spectating %q', tostring(self)))
		while task.wait(tmw) do
			if coroutine.status(self) == 'dead' then
				warn(string.format('Coroutine %q is dead', tostring(self)))
				break
			end
		end
	end)
end

function private.DoVisualVector3 (self: Vector3)
	local att = Instance.new('Attachment')
	att.Position = self
	att.Visible = true
	att.Name = 'VisualVector3'
	att.Parent = dbg
	
	Debris:AddItem(att, 10)
	return att
end

function private.DoVisualRaycast (self: Vector3, to: Vector3)
	local ray = Instance.new('Part')
	ray.Anchored = true
	ray.CanCollide = false
	ray.CanTouch = false
	ray.CanQuery = false
	ray.Transparency = 0.25
	ray.Material = Enum.Material.Neon
	ray.Size = Vector3.new(0.1, 0.1, (to-self).Magnitude)
	ray.CFrame = CFrame.new((self+to)/2, to)
	ray.Parent = dbg
	Debris:AddItem(ray, 10)
	return ray
end

function private.DoMeasureTimeForCalledFunction (func: (...any)->()|any, ...: any)
	local start = os.clock()
	func(...)
	return os.clock() - start
end

function private.DoTaskReturnTest (func: (...any)->any, ...: any)
	local time = os.clock()
	local id = HttpService:GenerateGUID(false)
	print('Received new task, arguments is ', {...}, ' , time is ', time, ' , id is ', id)
	local res = func(...) :: any
	warn('Task end for id ', id, ' , time is ', os.clock()-time)
	return res
end


-- Returns coroutine-watcher at table lifecycle.
function plugin.Translate (data: {}|{[any]:any}) : thread
	return private.DoRoot(data)
end
-- Returns task-wathcher at coroutine lifecycle.
function plugin.Spectate (coroutine: thread) : thread
	return private.DoSpectateAtCoroutine(coroutine)
end
-- Visualise vector3.
function plugin.Visualize3 (self: Vector3)
	return private.DoVisualVector3(self)
end
-- Visualise raycast.
function plugin.VisualizeRaycast (self: Vector3, to: Vector3)
	return private.DoVisualRaycast(self,to)
end
-- Returns time for function called.
function plugin.DoMeasureTime (func: (...any)->()|any, ...: any)
	return private.DoMeasureTimeForCalledFunction(func, ...)
end
-- Returns time for function called, but also return it's result.
function plugin.TaskReturn (func: (...any)->any, ...: any)
	return private.DoTaskReturnTest(func, ...)
end

export type ancestors = self
export type self = typeof(plugin)

return plugin