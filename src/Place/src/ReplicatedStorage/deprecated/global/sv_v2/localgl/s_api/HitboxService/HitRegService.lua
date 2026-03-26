local gl = require('../')

local PlayersService = game:GetService('Players')
local HitboxService = require('./')
local instance = gl.Library.Hexagon.Classes.Instance()

local private = {}
local service

private.service={}
service=instance.new(private.service,'HitRegService'::'HitRegService')

function private.AnalyzeHits (hits: {BasePart})
	local plrs = {}	

	for i,v in hits do
		local h = v:FindFirstAncestorOfClass('Humanoid')
		if h then
			local root = assert(h.RootPart, 'Humanoid does not have a RootPart')
			local model = assert(root:FindFirstAncestorOfClass('Model'), 'Unexpected behavior')
			local plr = PlayersService:GetPlayerFromCharacter(model)

			if plr then
				table.insert(plrs, plr)
			end
		end
	end

	return plrs
end

-- Tries to hit a humanoids with a spherical shape.
function private:TryHitSpherical (AtHumanoid: Humanoid, Position: Vector3, Radius: number)
	local o = OverlapParams.new()
	o.FilterDescendantsInstances = HitboxService:GetAllHumanoidHitboxes({AtHumanoid}) :: {Instance}
	o.FilterType = Enum.RaycastFilterType.Exclude
	
	local hits = workspace:GetPartBoundsInRadius(Position, Radius, o)
	return private.AnalyzeHits(hits)
end

-- Tries to hit a humanoids with a box.
function private:TryHitBox (AtHumanoid: Humanoid, CFrame: CFrame, Size: Vector3)
	local o = OverlapParams.new()
	o.FilterDescendantsInstances = HitboxService:GetAllHumanoidHitboxes({AtHumanoid}) :: {Instance}
	o.FilterType = Enum.RaycastFilterType.Exclude
	
	local hits = workspace:GetPartBoundsInBox(CFrame, Size, o)
	return private.AnalyzeHits(hits)
end

-- Tries to hit received players characters by using raycast
function private:CheckHit (From: BasePart, AtPlayers: {Player})
	local RayParams = RaycastParams.new()
	local CharactersLists = {} :: {Model}
	
	for i,v in AtPlayers do
		local character = v.Character
		if character then
			table.insert(CharactersLists, character)
		end
	end
	
	RayParams.FilterDescendantsInstances = {From}
	RayParams.FilterType = Enum.RaycastFilterType.Exclude
	
	local hits = {}
	for i,v in CharactersLists do
		local ray = workspace:Raycast(From.Position, (v:GetPivot().Position - From.Position).Unit * 1000, RayParams)
		if ray then
			if ray.Instance:IsDescendantOf(v) then
				table.insert(hits, v)
			end
		end
	end
	
	return hits
end

private.service.ScanSpherical = private.TryHitSpherical
private.service.ScanBox = private.TryHitBox
private.service.CanHit = private.CheckHit

return service