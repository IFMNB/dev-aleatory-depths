--!strict

local private = {}
local public = {}
-- Returns number type from: num, NaN, inf, -inf
function private.getspec (self: number): 'nan' | 'inf' | '-inf' | 'num'
	if self ~= self then
		return 'nan'
	else
		if self == math.huge then
			return 'inf'
		elseif self == -math.huge then
			return '-inf'
		else
			return 'num'
		end
	end
end
-- Checks is it value NaN, inf, -inf?
function private.isspec (self: number)
	return private.getspec(self) ~= 'num'
end
-- Checks is it value float?
function private.isfract (self: number)
	return math.floor(self)~=self
end
-- Checks is it value negative?
function private.isNegative (self: number)
	return math.abs(self)==self and self<0
end

public.GetNumberType = private.getspec
public.IsSpecial = private.isspec
public.IsFractional = private.isfract
public.IsNegative = private.isNegative
table.freeze(public)
table.freeze(private)

return public