local size = script.Parent.Frame.Size
local size2 = UDim2.new(0,0,0,0)
script.Parent.Activated:Connect(function(inputObject: InputObject, clickCount: number) 
	script.Parent.Frame.Size = script.Parent.Frame.Size ~= size and size or size2
	script.Parent.Frame.Visible = not script.Parent.Frame.Visible
end)