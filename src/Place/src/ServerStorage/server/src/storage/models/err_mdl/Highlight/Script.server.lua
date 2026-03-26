local tw = game:GetService('TweenService')
local twi = TweenInfo.new(0.25)
local twp1 = tw:Create(script.Parent, twi, {FillTransparency = 1})
local twp2 = tw:Create(script.Parent, twi, {FillTransparency = 0})
local twp3 = tw:Create(script.Parent, twi, {OutlineTransparency = 1})
local twp4 = tw:Create(script.Parent, twi, {OutlineTransparency = 0})

task.spawn(function ()
	while task.wait() do
		twp1:Play()
		task.wait(twi.Time)	
		twp2:Play()
		task.wait(twi.Time)
	end
end)
task.spawn(function()
	while task.wait() do
		twp3:Play()
		task.wait(twi.Time)	
		twp4:Play()
		task.wait(twi.Time)
	end
end)

warn('Model mismatch')