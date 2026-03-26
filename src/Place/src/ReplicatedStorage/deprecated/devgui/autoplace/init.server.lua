local debugscreen = script.debugScreen
local plr = assert(game.Players.LocalPlayer)
local plrgui = plr.PlayerGui

for i,v in script:GetDescendants() :: {Instance} do
	if v:IsA('ScreenGui') then
		local wr
		if v.ResetOnSpawn then
			wr = coroutine.wrap(function(...)
				plr.CharacterAdded:Connect(function(character: Model) 
					v:Clone().Parent = plrgui
				end)
			end)
		end
		
		v:Clone().Parent = plrgui
		if wr then wr() end
	end
end