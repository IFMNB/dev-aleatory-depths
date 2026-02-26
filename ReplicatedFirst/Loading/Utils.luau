local TweenService = game:GetService('TweenService')
local RunService = game:GetService('RunService')

local private = {}
local public = {}

function private.toMaxTransparent (item: TextLabel|TextButton, to: number)
	local origin = item.TextTransparency
	local tweenInfo = TweenInfo.new(1,
		Enum.EasingStyle.Exponential,
		Enum.EasingDirection.InOut
	)
	local tween = TweenService:Create(item, tweenInfo, {TextTransparency = to})
	tween:Play()
	return tween
end

function private.toMaxGraphemes (item: TextLabel)

	if item.MaxVisibleGraphemes < #item.Text then
		for i=1, #item.Text - item.MaxVisibleGraphemes do
			item.MaxVisibleGraphemes += 1
			task.wait(0.05/string.len(item.Text))
		end
	else
		for i=1, #item.Text do
			item.MaxVisibleGraphemes -= 1
			task.wait(0.05/string.len(item.Text))
		end
	end
end

function private.changeText (item: TextLabel, to: string)
	item.Text = to
	private.toMaxGraphemes(item);
end

function private.flexTransparency (item: TextLabel)
	local con : RBXScriptConnection
	local foo = false
	local origin = item.TextTransparency
	con = RunService.RenderStepped:Connect(function(deltaTime: number) 
		if foo then
			item.TextTransparency += 0.01/deltaTime
			if item.TextTransparency >= 1 then
				foo=not foo
			end
		else
			item.TextTransparency -= 0.01/deltaTime
			if item.TextTransparency <= 0 then
				foo=not foo
			end
		end

		item.TextTransparency = origin + (item.TextTransparency-origin)*0.01
	end)
	return function ()
		con:Disconnect()
		item.TextTransparency = origin
	end
end

function private.toColor3 (item: TextLabel, color3: Color3)
	local tweenInfo = TweenInfo.new(.5,
		Enum.EasingStyle.Back,
		Enum.EasingDirection.Out
	)
	local tween = TweenService:Create(item, tweenInfo, {TextColor3 = color3})
	tween:Play()
	return tween
end

function private.format (ThreadName: string, Count: number)
	return string.format('Preload %q thread with %s assets', ThreadName, tostring(Count))
end

function private.MoveTo (item: GuiObject, to: UDim2)
	local tweenInfo = TweenInfo.new(1.5,
		Enum.EasingStyle.Exponential,
		Enum.EasingDirection.InOut
	)
	local tween = TweenService:Create(item, tweenInfo, {Position = to})
	tween:Play()
	return tween
end

function private.Spin (item: GuiObject, time: number?)
	return task.spawn(function ()
		while true do
			local tweenInfo = TweenInfo.new(time or 1,
				Enum.EasingStyle.Linear
			--	Enum.EasingDirection.InOut
			);
			local tween = TweenService:Create(item, tweenInfo, {Rotation = item.Rotation+360})
			tween:Play()
			tween.Completed:Wait()
		end
	end)
end

function private.TransparencyTo (item: GuiObject, to: number)
	local tweenInfo = TweenInfo.new(1,
		Enum.EasingStyle.Exponential,
		Enum.EasingDirection.InOut
	)
	local tween = TweenService:Create(item, tweenInfo, {BackgroundTransparency = to})
	tween:Play()
	return tween
end

function private.ImageTransparencyTo (item: ImageLabel|ImageButton, to: number)
	local tweenInfo = TweenInfo.new(1,
		Enum.EasingStyle.Exponential,
		Enum.EasingDirection.InOut
	)
	local tween = TweenService:Create(item, tweenInfo, {ImageTransparency = to})
	tween:Play()
	return tween
end

public.LerpColor3 = private.toColor3
public.FlexTransparency = private.flexTransparency
public.ToMaxTransparent = private.toMaxTransparent
public.ToMaxGraphemes = private.toMaxGraphemes
public.ChangeText = private.changeText
public.PreloadFormat = private.format
public.MoveTo = private.MoveTo
public.TransparencyTo = private.TransparencyTo
public.ImageTransparencyTo = private.ImageTransparencyTo
public.Spin = private.Spin

return public