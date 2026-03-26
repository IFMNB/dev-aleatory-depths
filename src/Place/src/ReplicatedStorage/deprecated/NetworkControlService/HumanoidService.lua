local gl = require('../')
local NetworkControlService = require('./')

local cor = gl.Library.CodeBox.Special.Coroutine()
local instance = gl.Library.Hexagon.Classes.Instance()

local private = {}
local service

private.service = {}
service = instance.new(private.service, 'HumanoidService'::'HumanoidService')

-- Manually ragdolizes a humanoid. Definetly, just a shell at humanoid:ChangeState
function private:Ragdoll <t0> (humanoid: Humanoid&t0)
	humanoid.EvaluateStateMachine = false
	humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	return humanoid::t0
end

-- Stuns a humanoid for a given amount of time
function private:Stun <t0> (humanoid: Humanoid&t0, time: number)
	private:Ragdoll(humanoid)
	cor.AsyncWait(function(OnEnd: () -> (), ...) 
		task.wait(time)
		return OnEnd()
	end)
	private:Unragdoll(humanoid)
	return humanoid :: t0
end
-- Just drop humanoid. He gets up after some time.
function private:FallDown <t0> (humanoid: Humanoid&t0)
	humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
	return humanoid::t0
end
-- Unragdolls humanoid.
function private:Unragdoll <t0> (humanoid: Humanoid&t0)
	humanoid.EvaluateStateMachine = true
	humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	return humanoid::t0
end

-- Punches humanoid.
function private:Punch <t0> (Humanoid: Humanoid&t0, Direction: Vector3)
	local root : BasePart = assert(Humanoid.RootPart, 'Humanod does not have a root part')
	NetworkControlService:CallOnServerSide(root, function(OnEnd: () -> (), ...)
		root:ApplyImpulse(Direction)
		root:ApplyAngularImpulse(-Direction)
		return OnEnd()
	end)
	return Humanoid::t0
end

-- Knockbacks humanoid.
function private:Knockback <t0> (humanoid: Humanoid & t0, Direction: Vector3, time: number, stuntime: number)
	private:Ragdoll(humanoid)
	private:Punch(humanoid, Direction)
	task.wait(time)
	private:Stun(humanoid, stuntime)
	return humanoid :: t0
end

-- Randomly stuns and ragdolls humanoid
function private:Bonk <t0> (humanoid: Humanoid & t0)
	return private:Knockback(humanoid, Vector3.new(math.random(100, 3000), math.random(100,3000), math.random(100, 3000)), math.random(1,3), math.random(1,3))
end


private.service.Ragdoll = private.Ragdoll
private.service.Stun = private.Stun
private.service.FallDown = private.FallDown
private.service.Unragdoll = private.Unragdoll
private.service.Punch = private.Punch
private.service.Knockback = private.Knockback
private.service.Bonk = private.Bonk

return service