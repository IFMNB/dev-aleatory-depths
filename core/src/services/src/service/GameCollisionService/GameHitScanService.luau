local main = require('../..')
local Mapping = main.Mapping
local private = {}
local interface = {}

type GameHitService = typeof(interface.Service)
local GameCollisionService = require('./')
local HxSnapshot = main.Core.Classes.HxSnapshot()
local DebrisService = game:GetService('Debris')

function private.SortForPlayers (this: {BasePart})
	local result = {} :: {Model}
	for i,v in game.Players:GetPlayers() do
		local Character = v.Character
		if Character then
			for i0,v0 in this do
				if v0:IsDescendantOf(Character) then
					if table.find(result, Character) then continue end
					table.insert(result, Character)
				end
			end
		end
	end
	return result
end

function private.SortForFirstModelAncestor (This: {BasePart})
	local result = {} :: {Model}
	for i,v in This do
		local Model = v:FindFirstAncestorWhichIsA('Model')
		if Model then
			table.insert(result, Model)
		end
	end
	return result
end

function private.log (position: Vector3, size: number, count, collider, parttype: Enum.PartType?)
	local self = interface.Service;
	if self:IsLogActive() then
		self:PrintLog(string.format('Casted Sphere, count == %s, collider = %q', tostring(count), tostring(collider)))
	end
end

function private:ScanSphereForFirstModelAncestor (Position: Vector3, Collision: GameCollisionService.PreRegisteredGroups?|string, size: number?)
	local self = self :: GameHitService;
	if not self:IsActive() then return HxSnapshot.new({}::{Model}) end
	size = size or 1
	
	local Overlap = OverlapParams.new()
	Overlap.RespectCanCollide = true
	Overlap.CollisionGroup=Collision or 'Default'
	
	local Parts = workspace:GetPartBoundsInRadius(Position, size or 1, Overlap)
	
	private.log(Position, size, #Parts, Collision, Enum.PartType.Ball)
	return HxSnapshot.new(private.SortForFirstModelAncestor(Parts))
end

function private:ScanCoordinateForFirstModelAncestor (Cframe: CFrame, Collision: GameCollisionService.PreRegisteredGroups?|string, size: Vector3?)
	local self = self :: GameHitService;
	if not self:IsActive() then return HxSnapshot.new({}::{Model}) end
	size = size or Vector3.one
	
	
	local Overlap = OverlapParams.new()
	Overlap.RespectCanCollide = true
	Overlap.CollisionGroup=Collision or 'Default'
	
	local Parts = workspace:GetPartBoundsInBox(Cframe, Vector3.one, Overlap)
	
	private.log(Cframe.Position, -1, #Parts, Collision, Enum.PartType.Ball)
	return HxSnapshot.new(private.SortForFirstModelAncestor(Parts))
end


function private:ScanSphereForPlayersCharacter (Position: Vector3, Collision: GameCollisionService.PreRegisteredGroups?|string, size: number?)
	local self = self :: GameHitService;
	if not self:IsActive() then return HxSnapshot.new({}::{Model}) end
	size = size or 1
	
	local Overlap = OverlapParams.new()
	Overlap.RespectCanCollide = true
	Overlap.CollisionGroup=Collision or 'Default'
	
	local Parts = workspace:GetPartBoundsInRadius(Position, size, Overlap)
	private.log(Position, size, #Parts, Collision, Enum.PartType.Ball)
	
	return HxSnapshot.new(private.SortForPlayers(Parts))
end

function private:ScanCoordinateForPlayersCharacter (Cframe: CFrame, Collision: GameCollisionService.PreRegisteredGroups?|string, size: Vector3?)
	local self = self :: GameHitService;
	if not self:IsActive() then return HxSnapshot.new({}::{Model}) end
	size = size or Vector3.one
	
	local Overlap = OverlapParams.new()
	Overlap.RespectCanCollide = true
	Overlap.CollisionGroup=Collision or 'Default'
	
	local Parts = workspace:GetPartBoundsInBox(Cframe, size, Overlap)
	private.log(Cframe.Position, -1, #Parts, Collision, Enum.PartType.Ball)
	
	return HxSnapshot.new(private.SortForPlayers(Parts))
end

function private:ScanRaycast (From: Vector3, To: Vector3, Collision: GameCollisionService.PreRegisteredGroups?|string)
	local self = self :: GameHitService;
	if not self:IsActive() then return HxSnapshot.new({Result = nil :: RaycastResult?}) end
	
	local Raycast = RaycastParams.new()
	Raycast.RespectCanCollide = true
	Raycast.CollisionGroup=Collision or 'Default'
	
	local Result = workspace:Raycast(From, To-From, Raycast)
	private.log(From, (To-From).Magnitude, Result and 1 or 0, Collision, Enum.PartType.Ball)
	
	if Result then
		return HxSnapshot.new({Result = Result :: RaycastResult?})
	else
		return HxSnapshot.new({Result = nil ::  RaycastResult?})
	end
end

function private:ScanRaycastForPlayersCharacter (From: Vector3, To: Vector3, Collision: GameCollisionService.PreRegisteredGroups?|string)
	local self = self :: GameHitService;
	if not self:IsActive() then return HxSnapshot.new({Result = nil :: RaycastResult?}) end
	
	local Raycast = RaycastParams.new()
	Raycast.RespectCanCollide = true
	Raycast.CollisionGroup=Collision or 'Default'
	
	local Result = workspace:Raycast(From, To-From, Raycast)
	private.log(From, (To-From).Magnitude, Result and 1 or 0, Collision, Enum.PartType.Ball)
	
	if Result then
		for i,v in game.Players:GetPlayers() do
			local Character = v.Character
			if Character then
				if Character == Result.Instance then
					return HxSnapshot.new({Result = Result :: RaycastResult?})
				elseif Character:IsDescendantOf(Result.Instance) then
					return HxSnapshot.new({Result = Result :: RaycastResult?})
				end
			end
		end
		
		return HxSnapshot.new({Result = nil :: RaycastResult?})
	else
		return HxSnapshot.new({Result = nil ::  RaycastResult?})
	end
end



interface.Enums = table.freeze({
	Null = Mapping.Enum.Null;
});
interface.Exceptions = table.freeze({
	CodeException = Mapping.Exception.CodeException;
});
interface.Service = main.Core.Classes.SadNetService().new({
	ScanSphereForModels = private.ScanSphereForFirstModelAncestor;
	ScanCoordinateForModels = private.ScanCoordinateForFirstModelAncestor;
	ScanSphereForCharacters = private.ScanSphereForPlayersCharacter;
	ScanCoordinateForCharacters = private.ScanCoordinateForPlayersCharacter;
	ScanRaycast = private.ScanRaycast;
	ScanRaycastForCharacters = private.ScanRaycastForPlayersCharacter;
	
	Name = 'GameHitScanService'::'GameHitScanService';
	IsControllable = false;
	Behavior = interface.Enums.Null :: index<typeof(interface.Enums), keyof<typeof(interface.Enums)>>;
})



return interface