--!strict

local linker = require('./')

local private = {}
local plugin = {}

private.References = {}:: {[Reference]: Link}
private.CanGet = setmetatable({}, {__mode = 'k'}) :: any
private.err = 'Forbidden operation'

function private.CreateNewReference(to: Link) : Reference
	local ref = {}
	private.References[ref]=to
	to.Destroying:Once(function() 
		private.References[ref]=nil
	end)
	return ref
end
function private.Root(to:Link)
	local is
	for i,v in pairs(private.References) do
		if v==to then
			is=i
		end
	end

	return is or private.CreateNewReference(to)
end


-- Referenced element links to lifetime of the referencing instance. While this intance is not destroyed, the referenced element will not be destroyed ANYWAY, even if the referenced element is not accesible.
function private.DoLinkInstance <t0> (this: t0|canLink, to: Link) : t0
	local t0 = typeof(this)
	assert(t0 == 'userdata' or t0 == 'table' or t0 == 'function', private.err)
	assert(not private.GetRef(this), private.err)

	local ref = private.Root(to)

	private.SetGet(this, ref)
	linker.Link(ref, this)
	return this
end
-- Unlinks this element from their instance.
function private.DoUnlinkInstance <t0> (this: t0|canLink) : t0
	linker.Unlink(private.GetRef(this), this)
	return this
end


function private.SetGet (this: canLink, to: Reference)
	private.CanGet[this]=to
end
-- Returns the reference of the specified element. While this element exists, all elements, referenced to this object thats is a reference to instance, will be protected from destruction.
function private.GetRef (this: canLink) : Reference
	return private.CanGet[this]
end
function private.GetLink (this: Reference) : Link
	return private.References[this]
end
-- Returns the instance of the specified element.
function private.Get (this: canLink) : Link
	return private.GetLink(private.GetRef(this))
end



plugin.Get = private.Get
plugin.Link = private.DoLinkInstance
plugin.Unlink = private.DoUnlinkInstance
plugin.GetReference = private.GetRef


type Reference = {}
type Link = Instance
type canLink = {}|func|any
type func = (...unknown)->unknown

export type ancestors = self
export type self = typeof(plugin)

return plugin