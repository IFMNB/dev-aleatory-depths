-- By Larsen-dev
-- https://github.com/Larsen-dev/tableToBuffer
-- Used because MIT (i'm too lazy to write something like this)
-- 15.02.2026 (22:51)
-- MODIFIED BY @IFMNB / @aftersky (17.05.2026 (00:20))

-- Made By Larsen264

--!native
--!strict

-- Types
export type v = Enum | EnumItem | boolean | string | number | Vector2 | Vector3 | CFrame | buffer  | { [v]: v } | {} | {v} | nil | unknown | {any} | {unknown} | {[unknown]: unknown}
export type t = {[t | v]: t | v }

-- Values
local intSizes = { 8, 16, 32 }

local accessedTypes = { "boolean", "number", "string", "Vector3", "CFrame", 'Enum', 'EnumItem', "table", "buffer", "Vector2" }

local indexes = {
	boolean = 0,
	int8 = 1,
	int16 = 2,
	int32 = 3,
	float = 4,
	["string"] = 5,
	["Vector3"] = 6,
	["CFrame"] = 7,
	["table"] = 8,
	["buffer"] = 9,
	['Vector2'] = 10,
	["EnumItem"] = 11,
	['Enum'] = 12
}

local sizes = {
	boolean = 1,
	int8 = 8,
	int16 = 16,
	int32 = 32,
	int64 = 64,
	float = 32,
	double = 64,
	["string"] = 8,
	["Vector3"] = 96,
	["Vector2"] = 64,
	["CFrame"] = 224,
	['EnumItem'] = 16,
	["Enum"] = 16,
}


-- Every enum added manually because roblox does not have some Enums in various machines.
-- In simple, we can't some needls in enums in other machines. Server can't read some client's EnumItems, etc

local enums = {
	Enum.KeyCode,
	Enum.HumanoidStateType,
	Enum.Material,
	Enum.UserInputType,
	Enum.UserInputState,
	Enum.MouseBehavior
}
local enumValues = {
	
}

for i,v in {Enum.KeyCode:GetEnumItems(),
	Enum.HumanoidStateType:GetEnumItems(),
	Enum.Material:GetEnumItems(),
	Enum.UserInputType:GetEnumItems(),
	Enum.UserInputState:GetEnumItems(),
	Enum.MouseBehavior:GetEnumItems()} do
	
	for i,v in v do
		table.insert(enumValues, v)
	end
end

-- Functions

--[=[
	@param b buffer;
	@param n number;
	@param size number;
	@param offset number?;
	
	@return ;
	
	Writes some signed integer to a buffer with given in bits offset. Uses
	2 complement method to represent the negative numbers.
]=]
local function writeInt(b: buffer, n: number, size: number, offset: number?)
	offset = offset or 0
	
	if n > 2^(size - 1) - 1 then
		n = 2^(size - 1) - 1
	elseif n < -2^(size - 1) then
		n = -2^(size - 1)
	end
	
	--assert(n >=  -2^(size - 1) and n <= 2^(size - 1), string.format('Number %s out of range for size %s', tostring(n), tostring(size)))
	assert(n == n, "Number must be a normal number (no nan)")
	assert(n ~= math.huge, "Number must be a normal number (no inf)")
	assert(n ~= -math.huge, "Number must be a normal number (no -inf)")
	
	local usigned = if n >= 0 then n else bit32.rshift(n, size) + n
	
	for index = 0, size - 1 do
		local bit = bit32.band(bit32.rshift(usigned, index), 1)
		buffer.writebits(b, offset + index, 1, bit)
	end
end

--[=[
	@param b buffer;
	@param n number;
	@param offset number?;
	
	@return ;
	
	Writes some signed 32 bit float to a buffer with given in bits offset.
]=]
local function writeFloat32(b: buffer, n: number, offset: number?)
	offset = offset or 0
	
	if n > 2^31 - 1 then
		n = 2^31 - 1
	elseif n < -2^31 then
		n = -2^31
	end
	
	--assert(n >= -2^31 and n <= 2^31 - 1, string.format('Number %s out of range for size %s', tostring(n), tostring(32)))
	assert(n == n, "Number must be a normal number (no nan)")
	assert(n ~= math.huge, "Number must be a normal number (no inf)")
	assert(n ~= -math.huge, "Number must be a normal number (no -inf)")
	
	local sign = if n > 0 then 0 else 1
	local exponent = math.floor(math.log(math.abs(n), 2))
	local mantissa = math.abs(n) / (2 ^ exponent) - 1
	
	local exponentBits = exponent + 127
	local mantissaBits = math.floor(mantissa * 2^23 + 0.5)
	
	local bits = bit32.bor(
		bit32.lshift(sign, 31),
		bit32.lshift(exponentBits, 23),
		bit32.lshift(mantissaBits, 0)
	)
	
	for index = 0, 31 do
		local bit = bit32.band(bit32.rshift(bits, index), 1)
		buffer.writebits(b, offset + index, 1, bit)
	end
end

--[=[
	@param b buffer;
	@param offset number?;
	
	@return number;
	
	Reads some signed 32 bit float from a given buffer with given in bits
	offset.
]=]
local function readFloat32(b: buffer, offset: number?)
	offset = offset or 0
	
	local bits = 0
	
	for index = 0, 31 do
		local bit = buffer.readbits(b, offset + index, 1)
		bits = bit32.bor(bits, bit32.lshift(bit, index))
	end
	
	local sign = bit32.rshift(bits, 31)
	local exponent = bit32.band(bit32.rshift(bits, 23), 0xff)
	local mantissa = bit32.band(bits, 0x7FFFFF)
	
	local value = (1 + mantissa/2^23) * 2^(exponent - 127)
	if sign == 1 then
		value = -value
	end
	
	return value
end

local function writeFloat16 (b: buffer, n: number, offset: number?)
	offset = offset or 0
	
	assert(n >= -2^16 and n <= 2^16 - 1, "Number out of range")
	assert(n == n, "Number must be a normal number (no nan)")
	assert(n ~= math.huge, "Number must be a normal number (no inf)")
	assert(n ~= -math.huge, "Number must be a normal number (no -inf)")
	
	local sign = if n > 0 then 0 else 1
	local exponent = math.floor(math.log(math.abs(n), 2))
	local mantissa = math.abs(n) / (2 ^ exponent) - 1
	
	local exponentBits = exponent + 15
	local mantissaBits = math.floor(mantissa * 2^10 + 0.5)
	
	local bits = bit32.bor(
		bit32.lshift(sign, 15),
		bit32.lshift(exponentBits, 10),
		bit32.lshift(mantissaBits, 0)
	)
	
	for index = 0, 15 do
		local bit = bit32.band(bit32.rshift(bits, index), 1)
		buffer.writebits(b, offset + index, 1, bit)
	end
end

local function readFloat16 (b: buffer, offset: number?)
	offset = offset or 0
	
	local bits = 0
	
	for index = 0, 15 do
		local bit = buffer.readbits(b, offset + index, 1)
		bits = bit32.bor(bits, bit32.lshift(bit, index))
	end
	
	local sign = bit32.rshift(bits, 15)
	local exponent = bit32.band(bit32.rshift(bits, 10), 0xff)
	local mantissa = bit32.band(bits, 512)
	
	local value = (1 + mantissa/2^10) * 2^(exponent - 15)
	--local value = (-1)^sign * (1 + mantissa / 2^10) * 2^(exponent - 15)
	if sign == 1 then
		value = -value
	end
	
	return value
end

--[=[
	@param b buffer;
	@param n number;
	@param offset number?;
	
	@return number;
	
	Reads some signed integer written using 2 complement method from a
	buffer with given in bits offset.
]=]
local function readInt(b: buffer, size: number, offset: number?)
	offset = offset or 0
	
	local n = 0
	
	for index = 0, size - 1 do
		local bit = buffer.readbits(b, offset + index, 1)
		n += bit * 2^index
	end
	
	local signBit = 2 ^ (size - 1)
	if n >= signBit then
		n -= 2^size
	end
	
	return n
end



--[=[
	@param b buffer;
	@param toCopy buffer;
	@param offset number?;
	
	@return ;
	
	Copies some buffer to another buffer at given in bits offset.
]=]
local function copyBuffer(b: buffer, toCopy: buffer, offset: number?)
	offset = offset or 0
	
	local lengthInBits = buffer.len(toCopy) * 8
	
	for index = 0, lengthInBits - 1 do
		buffer.writebits(b, offset + index, 1, buffer.readbits(toCopy, index, 1))
	end
end

--[=[
	@param b buffer;
	@param length number;
	@param offset number?;
	
	@return buffer;
	
	Reads some buffer from a given buffer at given in bits offset.
]=]
local function readCopiedBuffer(b: buffer, length: number, offset: number?): buffer
	offset = offset or 0
	local copiedBuffer = buffer.create(math.ceil(length / 8))
	
	for index = 0, length - 1 do
		buffer.writebits(copiedBuffer, index, 1, buffer.readbits(b, offset + index, 1))
	end
	
	return copiedBuffer
end

-- Vector3 To Buffer
local vector3ToBuffer = {}

--[=[
	@param v3 Vector3;
	
	@return buffer;
	
	Converts Vector3 to buffer. Every side threats as 32 bit floats.
]=]
function vector3ToBuffer.convert(v3: Vector3): buffer
	local v3Buffer = buffer.create(12)
	
	vector3ToBuffer.write(v3Buffer, v3)
	
	return v3Buffer
end

--[=[
	@param b buffer;
	@param v3 Vector3;
	@param offset number;
	
	@return ;
	
	Writes Vector3 in buffer at given in bits offset. Every side threats as
	32 bit floats.
]=]
function vector3ToBuffer.write(b: buffer, v3: Vector3, offset: number?)
	offset = offset or 0
	
	if buffer.len(b) * 8 - offset < sizes.Vector3 then
		error(string.format("buffer's length %d is not enough.", buffer.len(b) * 8))
	end
	
	writeFloat32(b, v3.X, offset + 0)
	writeFloat32(b, v3.Y, offset + 32)
	writeFloat32(b, v3.Z, offset + 64)
end

--[=[
	@param b buffer;
	@param offset number?;
	
	@return Vector3;
	
	Reads Vector3 from buffer at given in bits offset.
]=]
function vector3ToBuffer.read(b: buffer, offset: number?): Vector3
	offset = offset or 0
	
	local x = readFloat32(b, offset + 0)
	local y = readFloat32(b, offset + 32)
	local z = readFloat32(b, offset + 64)
	
	return Vector3.xAxis * x + Vector3.yAxis * y + Vector3.zAxis * z
end



local vector2ToBuffer = {}


--[=[
	@param v2 Vector2;
	
	@return buffer;
	
	Converts Vector2 to buffer. Every side threats as 32 bit floats.
]=]
function vector2ToBuffer.convert(v2: Vector2): buffer
	local v2Buffer = buffer.create(8)

	vector2ToBuffer.write(v2Buffer, v2)
	
	return v2Buffer
end

--[=[
	@param b buffer;
	@param v2 Vector2;
	@param offset number;
	
	@return ;
	
	Writes Vector2 in buffer at given in bits offset. Every side threats as
	32 bit floats.
]=]
function vector2ToBuffer.write (b: buffer, v2: Vector2, offset: number?)
	offset = offset or 0
	
	if buffer.len(b) * 8 - offset < sizes.Vector2 then
		error(string.format("buffer's length %d is not enough.", buffer.len(b) * 8))
	end
	
	writeFloat32(b, v2.X, offset + 0)
	writeFloat32(b, v2.Y, offset + 32)
end

--[=[
	@param b buffer;
	@param offset number?;
	
	@return Vector2;
	
	Reads Vector2 from buffer at given in bits offset.
]=]
function vector2ToBuffer.read (b: buffer, offset: number?): Vector2
	offset = offset or 0
	
	local x = readFloat32(b, offset + 0)
	local y = readFloat32(b, offset + 32)
	
	return Vector2.xAxis * x + Vector2.yAxis * y
end

-- CFrame To Buffer
local cframeToBuffer = {}

--[=[
	@param cf CFrame;
	
	@return buffer;
	
	Converts CFrame to buffer. Every side threats as 32 bit floats.
]=]
function cframeToBuffer.convert(cf: CFrame): buffer
	local cfBuffer = buffer.create(sizes.CFrame/8)
	cframeToBuffer.write(cfBuffer, cf, 0)
	return cfBuffer
end

--[=[
	@param b buffer;
	@param cf CFrame;
	@param offset number?;
	
	@return buffer;
	
	Writes CFrame to some buffer at given offset in bits. Every side
	threats as 32 bit floats.
]=]
function cframeToBuffer.write(b: buffer, cf: CFrame, offset: number?)
	offset = offset or 0
	
	if buffer.len(b) * 8 - offset < sizes.CFrame then
		error(string.format("buffer's length %d is not enough.", buffer.len(b) * 8))
	end
	
	local Axis, Angle = cf:ToAxisAngle()
	vector3ToBuffer.write(b, cf.Position, offset + 0)
	vector3ToBuffer.write(b, Axis.Unit, offset + 96)
	writeFloat32(b, Angle, offset + 192)
end

--[=[
	@param b buffer;
	@param offset number?;
	
	@return CFrame;
	
	Reads CFrame from buffer at given in bits offset.
]=]
function cframeToBuffer.read(b: buffer, offset: number?): CFrame
	offset = offset or 0
	
	local position = vector3ToBuffer.read(b, offset + 0)
	local axis = vector3ToBuffer.read(b, offset + 96)
	local angle = readFloat32(b, offset + 192)
	
	return CFrame.fromAxisAngle(axis, angle) + position
end

-- String To Buffer
local stringToBuffer = {}

--[=[
	@param str string;
	@return number;
	
	Returnes new buffer size in bits if it was generated using .convert() method.
]=]
function stringToBuffer.size(str: string): number
	return 24 + string.len(str) * 8
end

--[=[
	@param str string;
	
	@return buffer;
	
	Converts string into new buffer. Also writes at start its length.
]=]
function stringToBuffer.convert(str: string): buffer
	local size = stringToBuffer.size(str)
	local strBuffer = buffer.create(size / 8)
	
	buffer.writebits(strBuffer, 0, 24, size - 24)
	
	for index = 1, string.len(str) do
		local numChar = string.byte(string.sub(str, index, index))
		buffer.writebits(strBuffer, 24 + ((index - 1) * 8), 8, numChar)
	end
	
	return strBuffer
end

--[=[
	@param b buffer;
	@param str string;
	@param scopeOffset number?;
	@param offset number?;
	
	@return ;
	
	Writes in buffer string at offset with its length at lengthOffset.
	Also offset and lengthOffset should be written in bits.
]=]
function stringToBuffer.write(b: buffer, str: string, scopeOffset: number?, offset: number?)
	scopeOffset = scopeOffset or 0
	offset = offset or scopeOffset + 24
	
	local size = stringToBuffer.size(str)
	
	if buffer.len(b) * 8 - offset < size - 24 then
		error(string.format("buffer's length %d is not enough.", buffer.len(b)))
	end
	
	buffer.writebits(b, scopeOffset, 24, size - 24)
	
	for index = 1, string.len(str) do
		local numChar = string.byte(string.sub(str, index, index))
		buffer.writebits(b, offset + ((index - 1) * 8), 8, numChar)
	end
end

--[=[
	@param b buffer;
	@param scopeOffset number?;
	@param offset number?;
	
	@return string;
	
	Reads written in buffer string, written using .write() or .convert() methods.
	Does not work with buffer made using buffer.fromstring() method.
	Also offset and lengthOffset should be written in bits, not in bytes.
]=]
function stringToBuffer.read(b: buffer, scopeOffset: number?, offset: number?): string
	scopeOffset = scopeOffset or 0
	offset = offset or scopeOffset + 24
	
	local length = buffer.readbits(b, scopeOffset, 24) / 8
	local strBuffer = buffer.create(length)
	
	for index = 0, length - 1 do
		local numChar = buffer.readbits(b, offset + index * 8, 8)
		buffer.writebits(strBuffer, index * 8, 8, numChar)
	end
	
	return buffer.tostring(strBuffer)
end

-- Values
local SCOPE_SIZE = 28



-- Table To Buffer functions

--[=[
	@param n number;
	
	@return number;
	
	Counts what size some number is in bits. Returns only 8, 16, 32.
]=]
local function returnNumberSizeInBits(n: number)
	for _, size in intSizes do
		if n >= -(2^size / 2) and n <= 2^size / 2 - 1 then
			return size
		end
	end
	
	warn(string.format("%d is out of bit size range: 8, 16, 32.", n))
	
	return 64
end

--[=[
	@param v any;
	
	@return string;
	
	Checks and returns type of given value and returnes it's adapted string
	equivalent.
]=]
local function checkAndReturnValueType(v: any): 'float16' | 'double' | 'float' | 'int8' | 'int16' | 'int32' | 'int64' | string
	local vType = typeof(v)
	
	if not table.find(accessedTypes, vType) then
		error(string.format("%s is not an accessed type.", vType))
	end
	
	if vType == "number" then
		if v % 1 ~= 0 then
			local float = tonumber(string.gsub(tostring(v), "%d+%.", "")) :: number;
			
			return 'float'
			--[[
			if float <= 2^16 - 1 or float >= -(2^16) then
				return "float16"
			elseif v <= 2^32 - 1 or v >= -(2^32) then
				return "float"
			else
				return "double"
			end
			]]
		end
		
		local bitSize = returnNumberSizeInBits(v)
		
		if bitSize == 8 then
			return "int8"
		elseif bitSize == 16 then
			return "int16"
		elseif bitSize == 32 then
			return "int32"
		elseif bitSize == 64 then
			return "int64"
		end
	end
	
	return vType
end

local enumToBuffer = {}

function enumToBuffer.convert(v: Enum)
	local b = buffer.create(2)
	enumToBuffer.write(b, v)
	return b
end

function enumToBuffer.write(b: buffer, v: Enum, offset: number?)
	writeInt(b, assert(table.find(enums::{Enum},v),'Enum not supported'), 16, offset)
end

function enumToBuffer.read(b: buffer, offset: number?)
	return enums[readInt(b, 16, offset)]
end

local enumItemsToBuffer = {}

function enumItemsToBuffer.convert(v: EnumItem)
	local b = buffer.create(2)
	enumItemsToBuffer.write(b, v)
	return b
end

function enumItemsToBuffer.write(b: buffer, v: EnumItem, offset: number?)
	writeInt(b, assert(table.find(enumValues,v),'Enum not supported'), 16, offset)
end

function enumItemsToBuffer.read(b: buffer, offset: number?)
	return enumValues[readInt(b, 16, offset)]
end


local booleanToBuffer = {}

function booleanToBuffer.convert(v: boolean)
	local b = buffer.create(1)
	booleanToBuffer.write(b, v)
	return b
end

function booleanToBuffer.write(b: buffer, v: boolean, offset: number?)
	writeInt(b, v and 1 or 0,1, offset)
end

function booleanToBuffer.read(b: buffer, offset: number?)
	return readInt(b, 1, offset) == -1
end

local numberToBuffer = {}

function numberToBuffer.convert(v: number)
	local vType = checkAndReturnValueType(v)
	local size = vType == 'float' and 4 or vType == 'int8' and 1 or vType == 'int16' and 2 or vType == 'int32' and 4 or vType == 'int64' and 8 or 0
	local b = buffer.create(size)
	
	if vType == 'float' then
		writeFloat32(b ,v)
	else
		writeInt(b, v, size * 8)
	end
	
	return b
end

function numberToBuffer.convertf32(v: number)
	local b = buffer.create(4)
	numberToBuffer.writef32(b, v)
	return b
end

function numberToBuffer.writef32(b: buffer, v: number, offset: number?)
	writeFloat32(b, v, offset)
end

function numberToBuffer.readf32(b: buffer, offset: number?)
	return readFloat32(b, offset)
end


function numberToBuffer.converti32(v: number)
	local b = buffer.create(4)
	numberToBuffer.writei32(b, v)
	return b
end

function numberToBuffer.writei32(b: buffer, v: number, offset: number?)
	writeInt(b, v, 32, offset)
end

function numberToBuffer.readi32(b: buffer, offset: number?)
	return readInt(b, 32,offset)
end

--[[
function numberToBuffer.convertf16(f: number)
	error()
	local b = buffer.create(2)
	writeFloat16(b, f)
	return b
end

function numberToBuffer.writef16(b: buffer, f: number, offset: number?)
	error()
	writeFloat16(b, f, offset)
end

function numberToBuffer.readf16(b: buffer, offset: number?)
	error()
	return readFloat16(b, offset)
end
]]

function numberToBuffer.converti16(v: number)
	local b = buffer.create(2)
	numberToBuffer.writei16(b, v)
	return b
end

function numberToBuffer.writei16(b: buffer, v: number, offset: number?)
	writeInt(b, v, 16, offset)
end

function numberToBuffer.readi16(b: buffer, offset: number?)
	return readInt(b, 16, offset)
end



function numberToBuffer.converti8(v: number)
	local b = buffer.create(1)
	numberToBuffer.writei8(b, v)
	return b
end

function numberToBuffer.writei8(b: buffer, v: number, offset: number?)
	writeInt(b, v, 8, offset)
end

function numberToBuffer.readi8(b: buffer, offset: number?)
	return readInt(b, 8, offset)
end

numberToBuffer.getSize = checkAndReturnValueType

--[=[
	@param t t;
	
	@return number, number, number;
	
	Returns information about table: it's size in bytes, scopes size and byte size.
]=]
local function tableToBufferSize(t: t): (number, number, number)
	local scopesSize = 0
	local size = 24
	
	for key, value in t do
		scopesSize += SCOPE_SIZE * 2
		size += SCOPE_SIZE * 2
		
		local keyType = checkAndReturnValueType(key)
		local valueType = checkAndReturnValueType(value)
		
		if keyType == "string" then
			size += stringToBuffer.size(key :: string) - 24
		elseif keyType == "buffer" then
			size += buffer.len(key :: buffer) * 8
		else
			size += sizes[keyType :: string] :: number
		end
		
		if valueType == "string" then
			size += stringToBuffer.size(value :: string) - 24
		elseif valueType == "table" then
			size += tableToBufferSize(value :: t)
		elseif valueType == "buffer" then
			size += buffer.len(value :: buffer) * 8
		else
			size += sizes[valueType :: string] :: number
		end
	end
	
	return size, scopesSize, math.ceil(size / 8)
end

--[=[
	@param b buffer;
	@param scopeOffset: number;
	@param offset: number;
	@param value: string | number | boolean | Vector3 | CFrame;
	
	@return number, number;
	
	Writes some key with scopes into buffer. Scopes have information
	about what size is given key and how to transform it when reading.
	Returns next scope offset and next value offset.
]=]
local function writeKey(b: buffer, scopeOffset: number, offset: number, key: v | t): (number, number)
	local keyType = checkAndReturnValueType(key)
	
	local index = indexes[keyType]
	local size: number
	
	if keyType == "string" then
		size = stringToBuffer.size(key :: string) - 24
	elseif keyType == "buffer" then
		size = buffer.len(key :: buffer) * 8
	else
		size = sizes[keyType]
	end
	
	buffer.writebits(b, scopeOffset, 4, index)
	buffer.writebits(b, scopeOffset + 4, 24, size)
	
	if keyType == "string" then
		stringToBuffer.write(b, key :: string, scopeOffset + 4, offset)
	elseif keyType == "float" then
		writeFloat32(b, key :: number, offset)
	elseif keyType == "Vector3" then
		vector3ToBuffer.write(b, key :: Vector3, offset)
	elseif keyType == 'Vector2' then
		vector2ToBuffer.write(b, key :: Vector2, offset)
	elseif keyType == "CFrame" then
		cframeToBuffer.write(b, key :: CFrame, offset)
	elseif keyType == "boolean" then
		booleanToBuffer.write(b, key :: boolean, offset)
	elseif keyType == "buffer" then
		copyBuffer(b, key :: buffer, offset)
	else
		writeInt(b, key :: number, size, offset)
	end
	
	return scopeOffset + SCOPE_SIZE, offset + size
end

--[=[
	@param b buffer;
	@param scopeOffset: number;
	@param offset: number;
	@param value: string | number | boolean | Vector3 | CFrame | t;
	
	@return number, number;
	
	Writes some value with scopes into buffer. Scopes have information
	about what size is given value and how to transform it when reading.
	Returns next scope offset and next key offset.
]=]
local function writeValue(b: buffer, scopeOffset: number, offset: number, value: v | t): (number, number)
	local valueType = checkAndReturnValueType(value)
	local value : any = value

	
	local index = indexes[valueType]
	local size: number
	
	if valueType == "string" then
		size = stringToBuffer.size(value :: string) - 24
	elseif valueType == "table" then
		size = tableToBufferSize(value :: t)
	elseif valueType == "buffer" then
		size = buffer.len(value :: buffer) * 8
	else
		size = sizes[valueType]
	end
	
	buffer.writebits(b, scopeOffset, 4, index)
	buffer.writebits(b, scopeOffset + 4, 24, size)
	
	if valueType == "string" then
		stringToBuffer.write(b, value :: string, scopeOffset + 4, offset)
	elseif valueType == "float" then
		writeFloat32(b, value :: number, offset)
	elseif valueType == "Vector3" then
		vector3ToBuffer.write(b, value :: Vector3, offset)
	elseif valueType == "Vector2" then
		vector2ToBuffer.write(b, value :: Vector2, offset)
	elseif valueType == "CFrame" then
		cframeToBuffer.write(b, value :: CFrame, offset)
	elseif valueType == "boolean" then
		booleanToBuffer.write(b, value :: boolean, offset)
	elseif valueType == "Enum" then
		enumToBuffer.write(b, value :: Enum, offset)
	elseif valueType == 'EnumItem' then
		enumItemsToBuffer.write(b, value :: EnumItem, offset)
	elseif valueType == "table" then
		local valueSize, valueScopesSize = tableToBufferSize(value :: t)
		
		local valueScopeOffset = offset + 24
		local valueOffset = offset + 24 + valueScopesSize
		
		buffer.writebits(b, offset, 24, valueScopesSize)
		
		for key, valueInValue in value do
			valueScopeOffset, valueOffset = writeKey(b, valueScopeOffset, valueOffset, key)
			valueScopeOffset, valueOffset = writeValue(b, valueScopeOffset, valueOffset, valueInValue)
		end
	elseif valueType == "buffer" then
		copyBuffer(b, value :: buffer, offset)
	else
		writeInt(b, value :: number, size, offset)
	end
	
	return scopeOffset + SCOPE_SIZE, offset + size
end

-- Table To Buffer
local tableToBuffer = {}

--[=[
	@param t table;
	
	@return number, number, number;
	
	Iterates through table and returnes sizes for future buffer: in bits,
	scopes size in bits and future buffer's size in bytes.
]=]
function tableToBuffer.size(t: t): (number, number, number)
	return tableToBufferSize(t)
end

--[=[
	@param tableToConvert t;
	
	@return buffer;
	
	Converts given table to buffer using this scheme:
	scopesSize (24) -> scopes (every 28 bit) -> key -> value.
]=]
function tableToBuffer.convert(t: t): buffer
	local size, scopesSize, sizeInBytes = tableToBuffer.size(t)
	local tBuffer = buffer.create(sizeInBytes)
	
	local scopesOffset = 24
	local offset = scopesSize + 24
	
	buffer.writebits(tBuffer, 0, 24, scopesSize)
	
	for key, value in t do
		scopesOffset, offset = writeKey(tBuffer, scopesOffset, offset, key)
		scopesOffset, offset = writeValue(tBuffer, scopesOffset, offset, value)
	end
	
	return tBuffer
end

function tableToBuffer.write(b: buffer, t: t, scopesOffset: number?, offset: number?)
	local size, scopesSize, sizeInBytes = tableToBuffer.size(t)
	
	scopesOffset = scopesOffset or 24
	offset = offset or scopesSize + 24
	
	if buffer.len(b) * 8 - offset < size then
		error(string.format("buffer's length %d is not enough", buffer.len(b)))
	end
	
	buffer.writebits(b, 0, 24, scopesSize)
	
	for key, value in t do
		scopesOffset, offset = writeKey(b, scopesOffset, offset, key)
		scopesOffset, offset = writeValue(b, scopesOffset, offset, value)
	end
end

--[=[
	@param b buffer;
	
	@return t;
	
	Reads written in given buffer table using this scheme:
	scopesSize (24) -> scopes (every 28 bit) -> key -> value.
]=]
function tableToBuffer.read(b: buffer, scopesOffset: number?, offset: number?) : t
	scopesOffset = scopesOffset or 0
	
	local scopesSize = buffer.readbits(b, scopesOffset, 24)
	
	scopesOffset += 24
	offset = offset or scopesOffset + scopesSize
	
	local descriptors = {} :: { {
		keyIndex: number,
		keySize: number,
		keySizeOffset: number,
		valueIndex: number,
		valueSize: number,
		valueSizeOffset: number,
	} }
	local readOffset = scopesOffset
	
	while readOffset < scopesOffset + scopesSize do
		local keyIndex = buffer.readbits(b, readOffset, 4)
		local keySize = buffer.readbits(b, readOffset + 4, 24)
		
		local valueIndex = buffer.readbits(b, readOffset + SCOPE_SIZE, 4)
		local valueSize = buffer.readbits(b, readOffset + SCOPE_SIZE + 4, 24)
		
		table.insert(descriptors, {
			keyIndex = keyIndex,
			keySize = keySize,
			keySizeOffset = readOffset + 4,
			valueIndex = valueIndex,
			valueSize = valueSize,
			valueSizeOffset = readOffset + SCOPE_SIZE + 4,
		})
		
		readOffset += SCOPE_SIZE * 2
	end
	
	local t = {} :: t
	
	for _, descriptor in ipairs(descriptors) do
		local key
		if descriptor.keyIndex == indexes["string"] then
			key = stringToBuffer.read(b, descriptor.keySizeOffset, offset)
		elseif descriptor.keyIndex == indexes["Vector3"] then
			key = vector3ToBuffer.read(b, offset)
		elseif descriptor.keyIndex == indexes["CFrame"] then
			key = cframeToBuffer.read(b, offset)
		elseif descriptor.keyIndex == indexes["Vector2"] then
			key = vector2ToBuffer.read(b, offset)
		elseif descriptor.keyIndex == indexes['Enum'] then
			key = enumToBuffer.read(b, offset)
		elseif descriptor.keyIndex == indexes["EnumItem"] then
			key = enumItemsToBuffer.read(b, offset)
		elseif descriptor.keyIndex == indexes["boolean"] then
			key = booleanToBuffer.read(b, offset)
		elseif descriptor.keyIndex == indexes["float"] then
			key = readFloat32(b, offset)
		elseif descriptor.keyIndex == indexes["buffer"] then
			key = readCopiedBuffer(b, descriptor.keySize, offset)
		else
			key = readInt(b, descriptor.keySize, offset)
		end
		
		offset += descriptor.keySize
		
		local value
		if descriptor.valueIndex == indexes["string"] then
			value = stringToBuffer.read(b, descriptor.valueSizeOffset, offset)
		elseif descriptor.valueIndex == indexes["Vector3"] then
			value = vector3ToBuffer.read(b, offset)
		elseif descriptor.valueIndex == indexes["Vector2"] then
			value = vector2ToBuffer.read(b, offset)
		elseif descriptor.valueIndex == indexes['Enum'] then
			value = enumToBuffer.read(b, offset)
		elseif descriptor.valueIndex == indexes["EnumItem"] then
			value = enumItemsToBuffer.read(b, offset)
		elseif descriptor.valueIndex == indexes["CFrame"] then
			value = cframeToBuffer.read(b, offset)
		elseif descriptor.valueIndex == indexes["boolean"] then
			value = booleanToBuffer.read(b, offset)
		elseif descriptor.valueIndex == indexes["float"] then
			value = readFloat32(b, offset)
		elseif descriptor.valueIndex == indexes["table"] then
			value = tableToBuffer.read(b, offset)
		elseif descriptor.valueIndex == indexes["buffer"] then
			value = readCopiedBuffer(b, descriptor.valueSize, offset)
		else
			value = readInt(b, descriptor.valueSize, offset)
		end
		
		offset += descriptor.valueSize
		
		t[key] = value
	end
	
	return t
end

local TypeMapping = table.freeze({
	['table'] = tableToBuffer;
	['string'] = stringToBuffer;
	['Vector3'] = vector3ToBuffer;
	['Vector2'] = vector2ToBuffer;
	['CFrame'] = cframeToBuffer;
	['boolean'] = booleanToBuffer;
	['number'] = numberToBuffer;
	['Enum'] = enumToBuffer;
	['EnumItem'] = enumItemsToBuffer;
})



return table.freeze({
	Table = table.freeze(tableToBuffer);
	String = table.freeze(stringToBuffer);
	Vector3 = table.freeze(vector3ToBuffer);
	Vector2 = table.freeze(vector2ToBuffer);
	CFrame = table.freeze(cframeToBuffer);
	Boolean = table.freeze(booleanToBuffer);
	Number = table.freeze(numberToBuffer);
	Enum = table.freeze(enumToBuffer);
	EnumItem = table.freeze(enumItemsToBuffer);
	BitSizes = table.freeze(sizes);
	AllowedTypes = table.freeze(accessedTypes);
	TypesMap = TypeMapping :: typeof(TypeMapping) & {[string]: {convert: (this: any)->buffer, [unknown]: any }};
})