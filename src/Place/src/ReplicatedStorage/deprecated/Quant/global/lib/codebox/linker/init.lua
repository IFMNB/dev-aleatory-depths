--!strict

local private = {}
local plugin = {}



private.links = {} :: {[links]:links}
private.to = setmetatable({}, {__mode = 'k'}) :: any
private.err1 = 'Forbidden operation'
private.err2 = 'Unknown error'

-- Destroys element from 'strong' storage.
function private.DoUnsave (self: links)
	private.links[self] = nil
	return self
end
-- Saves element in 'strong' storage. _GC will not be able to collect it.
function private.DoSave (self: links)
	assert(private.links[self] == nil, private.err1)
	private.links[self]=self
	return self
end



function private.DoCreateLink (self: links)
	private.to[self]=private.to[self] or {}
	return self
end

function private.DoDestroyLink (self: links)
	private.to[self] = if #private.to[self] == 0 then nil else private.to[self]
	return self
end
-- Targets this element to other elements. When this element is destroyed, it will also destroy the target elements, if this elements is not 'strong'.
function private.DoLinkTo (self: links, ...: links)
	debug.profilebegin(script.Name..'.LinkTo')

	private.DoCreateLink(self)
	for i,v in ipairs({...}) do
		assert(not table.find(private.to[self], v), private.err1)
		table.insert(private.to[self], v)

	end
	debug.profileend()
	return self
end
-- Unlinks from this element referenced elements.
function private.DoUnlinkTo (self: links, ...: links)
	debug.profilebegin(script.Name..'.UnlinkTo')

	for i,v in ipairs({...}) do
		table.remove(private.to[self], assert(table.find(private.to[self], v), private.err2))
	end
	private.DoDestroyLink(self)

	debug.profileend()
	return self
end


plugin.Unsave = private.DoUnsave
plugin.Save = private.DoSave
plugin.Link = private.DoLinkTo
plugin.Unlink = private.DoUnlinkTo
table.freeze(plugin)
table.freeze(private)

type links = any
export type ancestors = self
export type self = typeof(plugin)

return plugin