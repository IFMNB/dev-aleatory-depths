local vf = Instance.new 'VectorForce'
vf.Parent = script
local at = Instance.new 'Attachment'
at.Parent = script.Parent

vf.ApplyAtCenterOfMass = true
vf.Attachment0 = at
vf.RelativeTo = Enum.ActuatorRelativeTo.World

game["Run Service"].PostSimulation:Connect(function(deltaTimeSim: number)
	local v = script.Parent.AssemblyLinearVelocity
	local m = script.Parent.AssemblyMass
	local g = workspace.Gravity
	local k = 0
	vf.Force = Vector3.new(0, m*g, 0) - Vector3.new(0,v.Y,0) * k
end)