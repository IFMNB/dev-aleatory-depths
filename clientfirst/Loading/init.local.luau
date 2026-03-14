local StartLoadTime = os.clock()
local player = game:GetService('Players').LocalPlayer :: Player
local GUI = player:FindFirstChildOfClass('PlayerGui') or player:WaitForChild('PlayerGui') :: PlayerGui
local ContentProvider = game:GetService('ContentProvider')
local RunService = game:GetService('RunService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local TweenService = game:GetService('TweenService')

local ContentPreloader = require(script.ContentPreloader)
local Utils = require(script.Utils)

local function EnableClient () : never	
	for i=1, 6 do
		local scripts = player.PlayerScripts:GetDescendants()
		for _, v in scripts do
			if v:IsA('LocalScript') or v:IsA('Script') then
				if v.Name == 'main' then
					v.Enabled = true
					return nil :: never
				end
			end
		end
		
		task.wait(i)
	end
	
	return error('Scripts should have "main" script to start the game')
end

if game["Run Service"]:IsStudio() then
	EnableClient()
	game:GetService('Debris'):AddItem(script.Parent)
	return
end




local LoadGui = Instance.new('ScreenGui')
LoadGui.Name = 'LoadGui'
LoadGui.IgnoreGuiInset = true
LoadGui.ResetOnSpawn = false
LoadGui.DisplayOrder = -2
LoadGui.Parent = GUI

local LoadFrame = Instance.new('Frame')
LoadFrame.Size = UDim2.fromScale(1,1)
LoadFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
LoadFrame.Parent = LoadGui
LoadFrame.ZIndex=1

local InfoLowFrame = Instance.new('Frame')
InfoLowFrame.Size = UDim2.fromScale(1,.05)
InfoLowFrame.BackgroundTransparency = 1
InfoLowFrame.Parent = LoadGui
InfoLowFrame.Position =  UDim2.fromScale(0,2)
InfoLowFrame.ClipsDescendants=true
InfoLowFrame.ZIndex=10

local InfoListLayout = Instance.new('UIGridLayout')
InfoListLayout.FillDirection = Enum.FillDirection.Horizontal
InfoListLayout.CellPadding = UDim2.fromScale(.2,1)
InfoListLayout.SortOrder = Enum.SortOrder.LayoutOrder
InfoListLayout.HorizontalAlignment=Enum.HorizontalAlignment.Right
InfoListLayout.CellSize = UDim2.fromScale(.2,.5)
InfoListLayout.Parent = InfoLowFrame
InfoListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

local Stroke = Instance.new('UIStroke')
Stroke.Parent = InfoLowFrame
Stroke.Thickness = 0.4
Stroke.Color = Color3.new(255,0,0)

local OG_InfoLowFramePos = InfoLowFrame.Position
game.ReplicatedFirst:RemoveDefaultLoadingScreen()
Utils.MoveTo(InfoLowFrame, UDim2.fromScale(0,.95)).Completed:Wait()

local DefaultUiCorner = Instance.new('UICorner')
DefaultUiCorner.CornerRadius = UDim.new(0.65,0)

local LoadText = Instance.new('TextButton')
LoadText.Size = UDim2.fromScale(.1,1) --UDim2.fromScale(.10,.10)
LoadText.BackgroundTransparency = 1
LoadText.Text = 'Loading...'
LoadText.TextColor3 = Color3.fromRGB(255,255,255)
LoadText.Font = Enum.Font.GothamBold
LoadText.TextScaled = true
LoadText.Parent = InfoLowFrame
LoadText.TextWrapped=true
LoadText.TextScaled=true
LoadText.ZIndex = 1
LoadText.LayoutOrder = 10
LoadText.MaxVisibleGraphemes=0
LoadText.TextTransparency = 1
LoadText.RichText = true
DefaultUiCorner:Clone().Parent=LoadText

local LogoImage_p1 = Instance.new('ImageLabel')
LogoImage_p1.Image = 'rbxassetid://114240392962464'
LogoImage_p1.BackgroundTransparency = 1
LogoImage_p1.ImageTransparency = 1
LogoImage_p1.Parent = LoadFrame
LogoImage_p1.ScaleType = Enum.ScaleType.Fit
LogoImage_p1.AnchorPoint = Vector2.new(0.5,0.5)
LogoImage_p1.Position = UDim2.fromScale(0.5,0.5)
LogoImage_p1.Size = UDim2.fromScale(.4,.4) --UDim2.fromScale(0.25,.5)
LogoImage_p1.SizeConstraint = Enum.SizeConstraint.RelativeXX

local LogoImage_p2 = Instance.new('ImageLabel')
LogoImage_p2.Image = 'rbxassetid://76026063247314'
LogoImage_p2.BackgroundTransparency = 1
LogoImage_p2.ImageTransparency = 1
LogoImage_p2.Parent = LogoImage_p1
LogoImage_p2.ScaleType = Enum.ScaleType.Fit
LogoImage_p2.AnchorPoint = Vector2.new(0.5,0.5)
LogoImage_p2.Position = UDim2.fromScale(0.5,0.35)
LogoImage_p2.Size = UDim2.fromScale(.5,.5) --UDim2.fromScale(0.25,.5)

Utils.Spin(LogoImage_p1, 900)
Utils.Spin(LogoImage_p2, 40)
Utils.ImageTransparencyTo(LogoImage_p1, 0)
Utils.ImageTransparencyTo(LogoImage_p2, 0)

local function END_LOAD ()
	EnableClient()
	Utils.TransparencyTo(LoadText, 0).Completed:Wait();
	Utils.MoveTo(InfoLowFrame, OG_InfoLowFramePos)
	Utils.TransparencyTo(LoadFrame,1).Completed:Wait()
	Utils.ImageTransparencyTo(LogoImage_p2, 1).Completed:Wait()
	Utils.ImageTransparencyTo(LogoImage_p1, 1)
	Utils.ImageTransparencyTo(LogoImage_p2, 1).Completed:Wait()
end


local thread = task.spawn(function ()
	Utils.ToMaxTransparent(LoadText,0)
	LoadText.MaxVisibleGraphemes = #LoadText.Text-3
	while task.wait() do
		for i=1, 3 do
			LoadText.MaxVisibleGraphemes+=1
			task.wait(0.05*string.len(LoadText.Text))
		end
		for i=1, 3 do
			LoadText.MaxVisibleGraphemes-=1
			task.wait(0.05*string.len(LoadText.Text))
		end
	end
end)

do -- Skip loading
	local show = LoadText.MouseEnter:Connect(function(x: number, y: number) 
		Utils.TransparencyTo(LoadText, 0.85)
	end)
	local show2 = LoadText.MouseLeave:Connect(function(x: number, y: number) 
		Utils.TransparencyTo(LoadText, 1)
	end)

	LoadText.MouseButton1Click:Once(function() 
		show:Disconnect()
		show2:Disconnect()
		END_LOAD()
	end)
end




do -- Load assets
	
	local PreloadText = Instance.new('TextLabel')
	PreloadText.Size = UDim2.fromScale(.3,1)
	PreloadText.BackgroundTransparency = 1
	PreloadText.Text = '...'
	PreloadText.TextColor3 = Color3.fromRGB(102, 102, 102)
	PreloadText.Font = Enum.Font.GothamBold
	PreloadText.TextScaled = true
	PreloadText.Parent = InfoLowFrame
	PreloadText.TextWrapped=true
	PreloadText.MaxVisibleGraphemes=0
	PreloadText.ZIndex = 1
	PreloadText.LayoutOrder = 1
	PreloadText.TextTransparency = 1
	PreloadText.RichText = true


	local CurrentLoadText = Instance.new('TextLabel')
	CurrentLoadText.Size = UDim2.fromScale(.1,1)
	CurrentLoadText.BackgroundTransparency = 1
	CurrentLoadText.Text = 'itemname'
	CurrentLoadText.TextColor3 = Color3.fromRGB(80,80,80)
	CurrentLoadText.Font = Enum.Font.GothamBold
	CurrentLoadText.TextScaled = true
	CurrentLoadText.Parent = InfoLowFrame
	CurrentLoadText.TextWrapped=true
	CurrentLoadText.MaxVisibleGraphemes=0
	CurrentLoadText.ZIndex = 1
	CurrentLoadText.LayoutOrder = PreloadText.LayoutOrder+1
	CurrentLoadText.TextTransparency = 1
	CurrentLoadText.RichText = true

	
	local OG_preloadtext = PreloadText.Text
	local OG_preloadcolortext = PreloadText.TextColor3
	Utils.ToMaxTransparent(PreloadText,0)
	Utils.ToMaxTransparent(CurrentLoadText,0)
	

	local Main = ContentPreloader.new()
	Main:ToLoad(ReplicatedStorage:GetDescendants())
	Main:OnAssetLoad(function(asset: Instance)
		CurrentLoadText.Text = asset.Name;
		Utils.ToMaxGraphemes(CurrentLoadText);
	end)
	Main:OnLoaded(function()
		Utils.LerpColor3(CurrentLoadText, Color3.fromRGB(120, 255, 140))
		Utils.LerpColor3(PreloadText, Color3.fromRGB(120, 255, 140))
		Utils.ChangeText(PreloadText, 'Over...')
		Utils.ChangeText(CurrentLoadText, '...')
	end)

	Utils.ChangeText(PreloadText, Utils.PreloadFormat('Main',Main.Count))
	task.wait(2)
	Main:PreloadAsync()
	task.wait(1)


	local Misc = ContentPreloader.new()
	Misc:ToLoad(workspace:GetDescendants())
	Misc:OnAssetLoad(function(asset: Instance) 
		Utils.ChangeText(CurrentLoadText, asset.Name)
	end)
	Misc:OnLoaded(function() 
		Utils.LerpColor3(CurrentLoadText, Color3.fromRGB(77, 255, 37))
		Utils.LerpColor3(PreloadText, Color3.fromRGB(77, 255, 37))
		Utils.ChangeText(PreloadText, 'Over...')
		Utils.ChangeText(CurrentLoadText, '...')
	end)


	Utils.LerpColor3(PreloadText, OG_preloadcolortext)
	Utils.ChangeText(PreloadText, Utils.PreloadFormat('Misc',Misc.Count))
	CurrentLoadText.Text = '...';
	CurrentLoadText.TextColor3 = Color3.fromRGB(82,82,82);

	task.wait(3)
	Misc:PreloadAsync()
	task.wait(1)
	
	Utils.ToMaxTransparent(PreloadText,1)
	Utils.ToMaxTransparent(CurrentLoadText,1).Completed:Wait()
	
	PreloadText:Destroy()
	CurrentLoadText:Destroy()
	
end




if not game:IsLoaded() then game.Loaded:Wait() end


END_LOAD()

task.cancel(thread)
LoadGui:Destroy()
game:GetService('Debris'):AddItem(script.Parent)