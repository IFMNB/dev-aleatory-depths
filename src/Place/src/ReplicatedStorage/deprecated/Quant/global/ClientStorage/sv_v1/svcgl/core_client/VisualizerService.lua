--!strict

local gl = require('../')

local instance = gl.Library.Hexagon.Classes.Instance()
local ev = gl.Library.Hexagon.Classes.Events()

local private = {}

private.targetsFROM = {} :: {[PVInstance]: VisualizerTarget}
private.targetsTO = {} :: {[PVInstance]: VisualizerTarget}

private.call = {}
private.service = {}

private.ev_names = 'VisualEvent' :: 'VisualEvent'
private.service.OnApplyEvent, private.call.OnApplyEvent = ev.new(private.ev_names)
private.service.OnRemoveEvent, private.call.OnRemoveEvent = ev.new(private.ev_names)

-- Create new visualizer target.
function private.CreateNewVisualizerTarget (from: PVInstance, to: PVInstance, AlwaysVisualizeDistance: number)
	local visual = {}

	visual.Target = to
	visual.Transparency = 1
	visual.From = from
	visual.AlwaysVisualizeDistance = AlwaysVisualizeDistance

	return visual
end

type VisualizerTarget = typeof(private.CreateNewVisualizerTarget(workspace,workspace,1))

--[[Main handle operation of visualizer target.

We used Raycast (like deprecated workspace:Ray()) to define if target is visible or not,
and this also is a problem.

For be sure that target is visible, we need to check if raycast is hit our target and is not hit something else,
but this is not enough. Our Raycast casted only once, and if target is behind something, we will not see it,
but Raycast will return true, because it hit something, but not our target.
To fix this, we need to cast Raycast with redacted direction parameter again and check is it hit our target.

This realisation is not working correctly right now, but at this moment this is not our priority target.

@aftersky 30 11 2025
]]

-- Used to check is received cast.Instance is valid to continue main handle operation.
function private.DoCheckTargetRelability (self: VisualizerTarget, cast: RaycastResult)
	if not cast.Instance:IsDescendantOf(self.Target) then
		if self.Target ~= cast.Instance then
			return false
		end
	end

	return true
end

function private.CheckParents (self: VisualizerTarget)
	if not self.Target.Parent or not self.From.Parent then
		private:RemoveByFrom(self.From)
		coroutine.close(coroutine.running())
	end
end

-- Manually update the target.
function private.MainHandleOperation (VisualizerTarget: VisualizerTarget, deltaTime: number)
	private.CheckParents(VisualizerTarget)
	
	local RootPosition = VisualizerTarget.From:GetPivot().Position
	local TargetPosition = VisualizerTarget.Target:GetPivot().Position
	local Diff = TargetPosition-RootPosition
	
	local raycastParams = RaycastParams.new()
	raycastParams.RespectCanCollide = true
	raycastParams.BruteForceAllSlow = false
	raycastParams.IgnoreWater = true
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	
	local cast = workspace:Raycast(RootPosition,Diff,raycastParams)
	if cast then
		if not private.DoCheckTargetRelability(VisualizerTarget, cast) then
			VisualizerTarget.Transparency = 1
		else	
			local Dot = math.clamp(
				VisualizerTarget.From:GetPivot().LookVector:Dot(
				CFrame.lookAt(
					TargetPosition,
					RootPosition
				).LookVector
			), -math.huge, 1)
			
			local distance = Diff.Magnitude
			
			if distance <= VisualizerTarget.AlwaysVisualizeDistance then
				Dot += (VisualizerTarget.AlwaysVisualizeDistance-distance) / 8.5
			end
			
			local TransparencyFormula = (0.85 - Dot*0.85 - 0.25)
			
			VisualizerTarget.Transparency = math.clamp(1-TransparencyFormula, 0, 1)
		end
	end
	
	local list = VisualizerTarget.Target:GetDescendants() :: {Instance}
	table.insert(list, VisualizerTarget.Target)
	private.render(list, VisualizerTarget.Transparency, deltaTime)
end

function private.render (targets: {Instance}, to: number, dt: number)
	for i,v in targets do
		if v:IsA('BasePart')
			or v:IsA('ParticleEmitter')
			or v:IsA('Decal')
			or v:IsA('Beam')
			or v:IsA('Smoke')
			or v:IsA('Trail')
			or v:IsA('Sparkles')
			or v:IsA('Fire')
			or v:IsA('Explosion')
		then
			v.LocalTransparencyModifier = math.lerp(v.LocalTransparencyModifier, to, dt)
		end
	end
end

game:GetService('RunService').RenderStepped:Connect(function(deltaTime: number) 
	if not next(private.targetsFROM) then return end
	for i,v in pairs(private.targetsFROM) do
		coroutine.wrap(private.MainHandleOperation)(v::VisualizerTarget, deltaTime)
	end
end)
-- Applies new visualization effect to given instance. Visualization effect will be removed if @p1 or @p2 is destroyed.
function private:NewTarget (From: PVInstance, to: PVInstance, AlwaysVisualizeBeforeDistance: number)
	local visual = private.CreateNewVisualizerTarget(From,to, AlwaysVisualizeBeforeDistance)
	private.targetsFROM[From]=visual
	private.targetsTO[to]=visual
	private.call.OnApplyEvent(From, to, AlwaysVisualizeBeforeDistance)
end
-- Removes visualization effect from given instance. This instance should be a instance inside @param2 from service:New methode that you used before. 
function private:RemoveByTarget (Target: PVInstance)
	local visual = private.targetsTO[Target]
	if not visual then warn('VisualizerTarget already not exists for this target') return end
	private.targetsFROM[visual.From]=nil
	private.targetsTO[visual.Target]=nil
	
	local list = visual.Target:GetDescendants()
	table.insert(list, visual.Target)
	private.render(list, 0 ,1)
	private.call.OnRemoveEvent(nil, Target)
end
-- Removes visualization effect from given instance. This instance should be a instance inside @param1 from service:New methode that you used before. 
function private:RemoveByFrom (From: PVInstance) : ()
	local visual = private.targetsFROM[From]
	if not visual then warn('VisualizerTarget already not exists for this from') return end
	private.targetsFROM[visual.From]=nil
	private.targetsTO[visual.Target]=nil
	
	local list = visual.Target:GetDescendants()
	table.insert(list, visual.Target)
	private.render(list, 0 ,1)
	private.call.OnRemoveEvent(From, nil)
end

private.service.RemoveByFrom = private.RemoveByFrom
private.service.RemoveByTarget = private.RemoveByTarget
private.service.ApplyNewTarget = private.NewTarget

local service = instance.New(private.service, 'VisualizerService' :: 'VisualizerService')

table.freeze(private.service)
table.freeze(private)

return service