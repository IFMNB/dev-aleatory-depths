--!strict


local parent = require('./')
local str = require('../str')


local private = {}
local public = {}

setmetatable(public :: unknown, {__index = parent})

function private.fillstring (self: buffer, offtop: number, value: string)
	assert(str.IsASCII(value))

	local sp = value:split('')
	local ascii = str.GetCloneAllChars()
	local load = {}
	
	for i=1, #sp do
		local strk = assert(table.find(ascii, sp[i]), 'not ascii symbol detected.')
		table.insert(load, strk)
	end
	
	parent.includeu8(self, offtop, unpack(load))
	
	return self
end







-- Fills in the n positions from the specified position with a number that corresponds to string.char(number). Includes the n position
function public.fillStringu8 (self: buffer, offtop: number, value: string)
	return private.fillstring(self,offtop, value)
end

export type self = typeof(public)
export type ancestors = self & parent.ancestors

return public