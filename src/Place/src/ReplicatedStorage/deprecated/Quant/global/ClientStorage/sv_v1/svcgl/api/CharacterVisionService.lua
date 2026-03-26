local gl = require('./')
local Visualizer = gl.CoreClientApi.VisualizerService()
local instance = gl.Library.Hexagon.Classes.Instance()

local private = {}
local module = {}

function private.getallchars ()
	local p = game.Players:GetPlayers()
	local r = {}
	for i,v in p do
		if v == game.Players.LocalPlayer then continue end
		
		if v.Character then
			table.insert(r,v.Character)
		end
	end
	return r
end


local plr = assert(game.Players.LocalPlayer)

-- Connects Visualizer to CharacterAdded event.
function private:con ()
	do
		if module.CharacterAdded then
			assert(not module.CharacterAdded.Connected, 'CharacterAdded Connected twice')
		end
	end
	
	module.CharacterAdded = plr.CharacterAdded:Connect(function(character: Model) 
		local models = private.getallchars()
		for i,v in models do
			Visualizer:ApplyNewTarget(character, v, 40)
		end
	end)
end
-- Connects Visualizer to CharacterRemoving event.
function private:rem ()
	do
		if module.CharacterRemoved then
			assert(not module.CharacterRemoved.Connected, 'CharacterRemoved Connected twice')
		end
	end
	
	module.CharacterRemoved = plr.CharacterRemoving:Connect(function(character: Model) 
		local models = private.getallchars()
		for i,v in models do
			Visualizer:RemoveByTarget(v)
		end
	end)
end

private.con()
private.rem()

module.ConnectOnCharacterAdded = private.con
module.ConnectOnCharacterRemoved = private.rem

table.freeze(private)

return instance.New(module, 'CharacterVisionService' :: 'CharacterVisionService')