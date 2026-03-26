--!strict

local num = require('./')

local private = {}
local public = {}


-- Returns only positive bit size of number for target scheme.
function private.getunsignedbit (self: number)
	assert(not num.IsSpecial(self), 'this is spec number')
	assert(not num.IsFractional(self), 'this is float')
	return 2^self - 1
end
-- Returns a table of bits in the "signed" (i) scheme and awaited format.
function private.getsignedbit (self: number, result: 'i+'|'i-')
	assert(not num.IsSpecial(self), 'this is spec number')
	assert(not num.IsFractional(self), 'this is float')
	local r = (2^self)/2
	return result == 'i+' and r-1 or -r
end
-- Returns bit-map for 8,16,32,64 unsigned values
function private.getUnsignedBitMap ()
	local r : {number} = {}

	table.insert(r, private.getunsignedbit(8))
	table.insert(r, private.getunsignedbit(16))
	table.insert(r, private.getunsignedbit(32))
	table.insert(r, private.getunsignedbit(64))

	return r
end

-- Converts a number from "signed" scheme to "unsigned".
function private.convertuns (self: number)
	if num.IsNegative(self) then
		return (math.abs(self)*2)-1
	else
		return (math.abs(self)*2)+1
	end
end
-- Returns optimal bit region for this value.
function private.bitsize (self: number) : number?
	assert(not num.IsSpecial(self), 'this is a special num')
	self = num.IsNegative(self) and private.convertuns(self) or self
	
	local map = private.getUnsignedBitMap()

	for i,v in ipairs(map) do
		if self < v then
			return 8 * i
		end
	end
	
	return nil
end


-- Returns type for this value from: 'float', 'char', 'short int', 'int', 'long int'
function private.getinttype (self: number) : numType
	assert(not num.IsSpecial(self), 'this is a special num' ) 
	if num.IsFractional(self) then
		return 'float'
	end
	
	local size = private.bitsize(self) :: number
	
	if size <= 8 then
		return 'char'
	elseif size <= 16 then
		return 'short int'
	elseif size <= 32 then
		return 'int'
	elseif size > 32 then
		return 'long int'
	else
		return nil
	end
end
-- Returns 2 functions for read and write, considering the optimal bit size for the number.
function private.getbuffersized (self: number)
	local intType = private.getinttype(self)
	
	if intType == 'float' then
		return buffer.writef32, buffer.readf32
	elseif intType == 'char' then
		return buffer.writeu8, buffer.readu8
	elseif intType == 'short int' then
		return buffer.writeu16, buffer.readu16
	elseif intType == 'int' then
		return buffer.writeu32, buffer.readu32
	elseif intType == 'long int' then
		return buffer.writef64, buffer.readf64
	else
		error('unknown value type '..tostring(intType))
	end
end
-- Returns map from 1 to 64 for unsigned values
function private.generateSpecialUnsMap ()
	local r : {number} = {}
	for i=1, 64 do
		table.insert(r, private.getunsignedbit(i))
	end
	return r
end
-- Returns bit size for unsigned value.
function private.calculatebitsize(self: number)
	return math.floor(math.log(self, 2)) + 1
end

public.ConvertToUsigned = private.convertuns
public.GetUnsignedBit = private.getunsignedbit
public.GetSignedBit = private.getsignedbit
public.GetUnsignedBitMap = private.getUnsignedBitMap
public.GetWriteReadFor = private.getbuffersized
public.GetIntType = private.getinttype
public.GetDefaultBitRegion = private.bitsize
public.GetSpecialUnsignedBitMap = private.generateSpecialUnsMap
public.GetBitSize = private.calculatebitsize
table.freeze(private)
table.freeze(public)


export type numType = 'float' | 'char' | 'short int' | 'int' | 'long int' | nil 
export type self = typeof(public)
export type ancestors = self

return public   