--!strict

local private = {}

-- Returns the vector of the circle with radius, at and to.
function private.DoVector3GetCircle (self: Vector3, radius: number, at: number, to: number?)
	local to : number = to or at
	local new = self
	
	local angle = at * ( math.pi*2 / to)
	local x = math.cos(angle) * radius
	local z = math.sin(angle) * radius

	return new + Vector3.new(x, 0, z)
end
-- Returns the vector snapped to the grid.
function private.DoSnappedToGrid (self: Vector3, size: number)
	return (self//size)*size
end
-- Returns modulus of the vector from -1|1, thats related to the direction of the vectors - does he point to the same direction?
function private.DoView (self: Vector3, to: Vector3)
	local dir = private.DoDirection(self,to)
	return dir:Dot(to.Unit)
end

-- Get the angle between two vectors from first argument to second argument.
function private.DoDirection (self: Vector3, to: Vector3)
	return (to - self).Unit
end
-- Returns difference between two vectors.
function private.DoRotated (self: Vector3, at: Vector3) : CFrame
	local dot = self:Dot(at)
	local dif = 0.999
	
	if dot > dif then
		return CFrame.new()
	elseif dot < dif then
		return CFrame.fromAxisAngle(Vector3.new(1,0,0), math.pi)
	else
		return CFrame.fromAxisAngle(self:Cross(at), math.acos(dot))
	end
end

-- Returns direction vector of the circle with center in self.
function private.DoRadianDirection (self: Vector3, radian: number)
	local this = self.Unit
	
	local x,y = math.cos(radian), math.sin(radian)
	return Vector3.new(this.X+x,this.Y,this.Z+y)
end





local public = {}
public.GetDirectionFrom = private.DoDirection
public.GetViewFrom = private.DoView
public.GetSnapped = private.DoSnappedToGrid
public.GetCirclePosition = private.DoVector3GetCircle
public.GetRadianDirection = private.DoRadianDirection
public.GetRotationTo = private.DoRotated
table.freeze(public)
table.freeze(private)

return public