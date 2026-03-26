local private = {}
local public = {}	
local class = {}

private.mt = {__index=public, __metatable='Locked'}

function private.new ()
	local element = {}
	element.data = true
	setmetatable(element, private.mt)

	local proxy = newproxy(true)
	local mt = getmetatable(proxy)
	mt.__index=element
	mt.__newindex=element
	mt.__metatable=private.mt.__metatable
	mt.__call= function (call, ...) return (element::any)(...) end

	return proxy :: typeof(element)
end

function private:meow <t0> (mur: string|t0)
	print(mur)
end

public.meow = private.meow
class.new = private.new

return class