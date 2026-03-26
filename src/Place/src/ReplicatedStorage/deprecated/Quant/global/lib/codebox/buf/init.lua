--!strict

local private = {}
local public = {}

function private.includebyte (self: buffer, offtop: number, func: any, ...: number)
	local size = buffer.len(self)
	local work = size - offtop
	local insert = {...}
	
	assert(offtop<size, 'offtop out of buffer-bounds')
	assert(#insert<=work, 'out of buffer-bounds from all received values')

	local n=1
	for i=offtop, work do
		if n>#insert then break end
		func(self, i, insert[n]);
		n+=1
	end

	return self
end



-- Fills the buffer, inclusive of the specified position, with values ​​of this format as many as the values ​​were received. Accordingly, it does not check the type of bits of values.
function public.includeu8 (self: buffer, offtop: number, ...: number)
	return private.includebyte(self, offtop, buffer.writeu8, ...)
end
-- Fills the buffer, inclusive of the specified position, with values ​​of this format as many as the values ​​were received. Accordingly, it does not check the type of bits of values.
function public.includeu16 (self: buffer, offtop: number, ...: number)
	return private.includebyte(self, offtop, buffer.writeu16, ...)
end
-- Fills the buffer, inclusive of the specified position, with values ​​of this format as many as the values ​​were received. Accordingly, it does not check the type of bits of values.
function public.includeu32 (self: buffer, offtop: number, ...: number)
	return private.includebyte(self, offtop, buffer.writeu32, ...)
end
-- Fills the buffer, inclusive of the specified position, with values ​​of this format as many as the values ​​were received. Accordingly, it does not check the type of bits of values.
function public.includef32 (self: buffer, offtop: number, ...: number)
	return private.includebyte(self, offtop, buffer.writef32, ...)
end
-- Fills the buffer, inclusive of the specified position, with values ​​of this format as many as the values ​​were received. Accordingly, it does not check the type of bits of values.
function public.includef64 (self: buffer, offtop: number, ...: number)
	return private.includebyte(self, offtop, buffer.writef64, ...)
end


export type ancestors = self
export type self = typeof(public)

return public