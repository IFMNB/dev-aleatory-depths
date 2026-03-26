local UIS = game:GetService('UserInputService')
local RUN = game:GetService('RunService')
local CAMERA = assert(workspace.Camera, 'Camera not found')
--local PLAYER = assert(game:GetService('Players').LocalPlayer, 'LocalPlayer not found')
--local GUI = PLAYER.PlayerGui



local gl = require('../')
local hxc = gl.Library.Hexagon.Classes

local ContextService = gl.CoreApi.ContextService()
local ControlsService = require('./')

local Coordinate = gl.Library.CodeBox.Primetive.CFrame()
local cor = gl.Library.CodeBox.Special.Coroutine()
local int = hxc.Instance()
local ev = hxc.Events()

local private = {}
private.events = 'CameraEvent' :: 'CameraEvent'
private.svc, private.cl = {}, {}
private.svc.OnFreeCameraEvent,private.cl.OnFreeCameraEvent = ev.new(private.events)
private.svc.OnDefaultCameraEvent,private.cl.OnDefaultCameraEvent = ev.new(private.events)
private.svc.OnServiceUsedCameraEvent, private.cl.OnServiceUsedCameraEvent = ev.new(private.events)
private.svc.OnServiceStopUseCameraEvent, private.cl.OnServiceStopUseCameraEvent = ev.new(private.events)

private.svc.UseParallel = false

function private:WatchStopUseScriptable (f: ()->())
	local con : RBXScriptConnection
	con = CAMERA:GetPropertyChangedSignal('CameraType'):Connect(function()
		if CAMERA.CameraType ~= Enum.CameraType.Scriptable then
			con:Disconnect()
			f()
			private.cl.OnServiceStopUseCameraEvent()
		end
	end)
	return con
end

function private:ScriptableCamera ()
	if CAMERA.CameraType == Enum.CameraType.Scriptable then
		CAMERA.CameraType = Enum.CameraType.Custom
		task.wait()
		CAMERA.CameraType = Enum.CameraType.Scriptable
		
	else
		CAMERA.CameraType = Enum.CameraType.Scriptable
	end
	
	private.cl.OnServiceUsedCameraEvent()
end

--[[
local dMouse = UIS:GetMouseDelta()
				private.Desync()
				local uVec = (dMouse * 0.01) * UIS.MouseDeltaSensitivity
				local uX,uY,uZ = uVec.X,uVec.Y,0
				
				aY+=-math.rad(uY)
				aX+=-math.rad(uX)
			
				local angle = CFrame.fromEulerAnglesYXZ(aY,aX,uZ)
				local tarfr = CFrame.new(CAMERA.CFrame.Position)*angle
				local r0 = AbsoluteCinema and CAMERA.CFrame:Lerp(tarfr, delta*2) or tarfr
				private.Sync()
				CAMERA.CFrame = r0
]]

-- Enables special camera controller that emulates camera from RobloxStudio. Definetly have more controls than default one
function private:FreeCamera (CAMERA: Camera, Speed: number, AbsoluteCinema: boolean?)
	private:ScriptableCamera()
	
	local OriginSpeed = Speed * 100
	local speed = OriginSpeed
	
	local aY,aX = 0,0
	local cframe_buffer = CAMERA.CFrame
	local snapshot : CFrame?
	
	local registry = {}
	
	local inputs_on = {}
	inputs_on = {
		[Enum.KeyCode.W] = function (delta: number)
			return (Coordinate.CFrameMove(CAMERA.CFrame, speed, delta) - cframe_buffer.Position).Position
		end,
		[Enum.KeyCode.A] = function (delta: number)
			return (Coordinate.CFrameMoveSide(CAMERA.CFrame, -speed, delta)- cframe_buffer.Position).Position
		end,
		[Enum.KeyCode.S] = function (delta: number)
			return (Coordinate.CFrameMove(CAMERA.CFrame, -speed, delta)- cframe_buffer.Position).Position
		end,
		[Enum.KeyCode.D] = function (delta: number)
			return (Coordinate.CFrameMoveSide(CAMERA.CFrame, speed, delta)- cframe_buffer.Position).Position
		end,
		[Enum.KeyCode.E] = function (delta: number)
			return (Coordinate.CFrameMoveVertical(CAMERA.CFrame, speed, delta) - cframe_buffer.Position).Position
		end,
		[Enum.KeyCode.Q] = function (delta: number)
			return (Coordinate.CFrameMoveVertical(CAMERA.CFrame, -speed, delta) - cframe_buffer.Position).Position
		end
	}
	
	inputs_on[Enum.KeyCode.Space] = inputs_on[Enum.KeyCode.E]
	inputs_on[Enum.KeyCode.LeftControl] = inputs_on[Enum.KeyCode.Q]
	
	local inputs_spec = {}
	inputs_spec = {
		[Enum.KeyCode.LeftShift] = function ()
			speed *= 3
			return nil
		end,
		[Enum.KeyCode.LeftAlt] = function ()
			speed /= 2
			return nil
		end
	}
	local inputs_spec_off = {
		[Enum.KeyCode.LeftShift] = function ()
			speed /= 3
			return nil
		end,
		[Enum.KeyCode.LeftAlt] = function ()
			speed *= 2
			return nil
		end
	}
	
	local a0 = ControlsService:OnInput(function(input: InputObject) 
		if inputs_on[input.KeyCode] then
			registry[input.KeyCode] = inputs_on[input.KeyCode]
		end
		if inputs_spec[input.KeyCode] then
			inputs_spec[input.KeyCode]()
		end
	end, function(input: InputObject) 
		registry[input.KeyCode]=nil
		if inputs_spec_off[input.KeyCode] then
			inputs_spec_off[input.KeyCode]()
		end
	end)
	
	local r = ContextService:Run(private.svc.UseParallel, RUN.PreRender, function(Sync: (...any) -> (), Desync: (...any) -> (), delta: number)
		local buffer_render = {}
		
		for i,v in registry do
			local val : any = (v::any)(delta)
			table.insert(buffer_render, val)
		end
		
		if snapshot then
			if snapshot.Position ~= cframe_buffer.Position then
				cframe_buffer = snapshot
			end
		end
		
		for i,v in buffer_render do
			cframe_buffer+=v
		end
		
		snapshot = cframe_buffer
		
		Sync()
		CAMERA.CFrame = cframe_buffer
	end)
	
	
	local m0
	local m = ControlsService:OnUserInput(Enum.UserInputType.MouseButton2, function(input: InputObject)
		UIS.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
		m0 = private.RunContext(RUN.PreRender, function(delta: number) 
			private.Sync()
			
			local dMouse = UIS:GetMouseDelta()
			
			private.Desync()
			
			local uVec = (dMouse * 0.025) * UIS.MouseDeltaSensitivity
			local uX,uY,uZ = uVec.X,uVec.Y,0

			aY+=-math.rad(uY)
			aX+=-math.rad(uX)

			local angle = CFrame.fromEulerAnglesYXZ(aY,aX,uZ)
			local tarfr = CFrame.new(cframe_buffer.Position)*angle
			local r0 = AbsoluteCinema and cframe_buffer:Lerp(tarfr, delta*2) or tarfr
			
			private.Sync()
			
			-- aX and aY does not properly work when FreeCam has been initialized,
			-- so starter camera orienation is 0,0,0 at FC using start.

			cframe_buffer = r0 
		end)
	end, function(input: InputObject) 
		UIS.MouseBehavior = Enum.MouseBehavior.Default
		private:Disconnect(m0)
	end)
	
	private:WatchStopUseScriptable(function() 
		private:Disconnect(r)
		private:Disconnect(m)
		private:Disconnect(a0)
		private:Disconnect(m0)
	end)
	
	private.cl.OnFreeCameraEvent(speed, AbsoluteCinema)
end

-- Returns the camera to its default state.
function private:DefaultCamera (CAMERA: Camera)
	CAMERA.CameraType = Enum.CameraType.Custom
	private.cl.OnDefaultCameraEvent()
	private.cl.OnServiceStopUseCameraEvent()
end


-- Smoothly moves camera to target Vector3.
function private:MoveCameraTo (CAMERA: Camera, to: Vector3, Back: boolean?)
	private:ScriptableCamera()
	
	local con : RBXScriptConnection?
	local con2 : RBXScriptConnection?
	local con3 : RBXScriptConnection?
	local first = CAMERA.CFrame
	
	con2 = private:WatchStopUseScriptable(function() 
		private:Disconnect(con)
		private:Disconnect(con3)
	end)
	
	con = private.RunContext(RUN.PreRender, (function(delta: number) 
		local tar = CAMERA.CFrame:Lerp(CFrame.new(to) * CAMERA.CFrame.Rotation, delta)
		
		private.Sync()
		if (CAMERA.CFrame.Position - to).Magnitude < 0.085 then
			private:Disconnect(con)
			if not Back then
				private:Disconnect(con2)
				private:DefaultCamera(CAMERA)
			else
				con3 = private.RunContext(RUN.PreRender, function(delta: number) 
					local tar = CAMERA.CFrame:Lerp(CFrame.new(first.Position) * CAMERA.CFrame.Rotation, delta)
					
					private.Sync()
					
					if (CAMERA.CFrame.Position - first.Position).Magnitude < 0.085 then
						private:Disconnect(con2)
						private:Disconnect(con3)
						private:DefaultCamera(CAMERA)
					end
					
					CAMERA.CFrame = tar
				end)
			end
		end
		
		CAMERA.CFrame = tar
	end))
end
-- Smoothly rotates camera to target Vector3.
function private:RotateCameraTo (CAMERA: Camera, to: Vector3, Back: boolean?)
	private:ScriptableCamera()
	
	local con : RBXScriptConnection?
	local con2 : RBXScriptConnection?
	local con3 : RBXScriptConnection?
	local first = CAMERA.CFrame
	
	con2 = private:WatchStopUseScriptable(function() 
		private:Disconnect(con)
		private:Disconnect(con3)
	end)
	
	con = private.RunContext(RUN.PreRender, function(delta: number) 
		local look = CFrame.lookAt(CAMERA.CFrame.Position, to)
		local view = math.clamp(CAMERA.CFrame.LookVector:Dot(CFrame.lookAt(CAMERA.CFrame.Position, to).LookVector), -math.huge, 1)
		
		private.Sync()
		if view >= 0.99 then
			private:Disconnect(con)
			if Back then
			con3 = private.RunContext(RUN.PreRender, function(delta: number) 
				local look = CFrame.lookAt(CAMERA.CFrame.Position, first.LookVector * 1000)
				local view = math.clamp(CAMERA.CFrame.LookVector:Dot(CFrame.lookAt(
					CAMERA.CFrame.Position,
					first.LookVector * 1000
					).LookVector), -math.huge, 1)
				
				private.Sync()
				if view >= 0.99 then
					private:Disconnect(con3)
					private:Disconnect(con2)
					private:DefaultCamera(CAMERA)
				end
				
				CAMERA.CFrame = CAMERA.CFrame:Lerp(look, delta)
			end)
			else
				private:Disconnect(con2)
				private:DefaultCamera(CAMERA)
			end
		end
		
		CAMERA.CFrame = CAMERA.CFrame:Lerp(look, delta)
	end)
end


private.svc.SetDefaultCamera = private.DefaultCamera
private.svc.SetFreeCamera = private.FreeCamera
private.svc.MoveTo = private.MoveCameraTo
private.svc.RotateTo = private.RotateCameraTo

local service = int.New(private.svc, 'CameraService' :: 'CameraService')

return service