local vf = script.VectorForce
local k = 16
local d = k/2
local h = 4.235
local kH = 1.1
local cH = 0
local tH = h
local vY = 1
local m = 0
local g = workspace.Gravity
local st = false
local antiG = 0
local prevF = 0

local a0 = script.a0
local a1 = script.a1
local p0 = script.Part
local be = script.Beam

local cP = Vector3.zero
local rR
local rP = RaycastParams.new()
rP.FilterDescendantsInstances = script.Parent.Parent:GetDescendants()
rP.RespectCanCollide = true

game["Run Service"].Heartbeat:Connect(function(deltaTime: number)
	m = script.Parent.AssemblyMass
	g = workspace.Gravity
	
	cP = script.Parent:GetPivot()
	vY = script.Parent.AssemblyLinearVelocity.Y
	rR = workspace:Raycast(cP.Position + Vector3.new(0,h-(h-math.round(h)),0), -Vector3.yAxis*(h*kH), rP)
	if rR then
		cH = rR.Distance
		st = true
		be.Color = ColorSequence.new(Color3.new(0,255))
	else
		st = false
		be.Color = ColorSequence.new(Color3.new(255))
	end
	
	a0.Position = Vector3.new(0,cH)
	a1.Position = Vector3.new(0,tH)
	p0.Position = script.Parent.Position - Vector3.new(0,tH)
	
	
	local f = st and k*(tH-cH)-d*vY+g or 0
	local r = m*(f)
	
	prevF = vf.Force.Y
	vf.Force = Vector3.new(0, r, 0)

	
end)