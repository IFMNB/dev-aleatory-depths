return function (fr: Frame)
	local button = script.spawn:Clone() :: GuiButton
	button.Activated:Connect(function(inputObject: InputObject, clickCount: number) 
		script.Parent.events.Value.spawnbutton:FireServer()
	end)
	button.Parent = fr
end