--!strict
--!nolint DeprecatedApi

local private = {}
private.err = 'never'

--- Flips the table keys and values.
function private.flipper <k,v> (self: tbl<k,v>, clone: boolean, iter: iter)
	local r = clone and {} or self
	for i,v in private.getiter(iter)(self) do
		r[i]=nil
		r[v]=i
	end
	return r
end
-- Recursive table iterator.
function private.recursive (self: {}, iter: recursiveIter, callback: (this: anytbl, gate: any) -> any, name: string?)
	local r
	if iter == 'before' then
		r = callback(self ::anytbl, name)
		if r ~= nil then return r end
	end
	for i,v in pairs(self :: any) do
		if type(v) == 'table' then
			private.recursive(v, iter, callback, i)
		end
	end
	if iter == 'after' then
		r = callback(self :: anytbl, name)
		if r ~= nil then return r end
	end
	
	return nil
end
-- Recursive table copy.
function private.copy <t0> (self: t0): t0
	assert(typeof(self)=='table' or typeof(self)=='userdata', 'only table or userdata can be copied')
	
	local copy = {}
	for i,v in pairs(self :: {[any]: any}) do
		copy[private.copy(i :: any)]=private.copy(v :: any)
	end
	local mt = getmetatable(self)
	if mt then setmetatable(copy, mt) end

	return copy 
end

function private.iter_rpairs (state: {any}, control: number) : (number?,any)
	local i = control - 1
	if i >= 1 then
		return i, state[i]
	else
		return nil
	end
end
--[[Alternative copy of ipairs. Iterates from last to first element.
You should use this construction as an alternative:

for lastIndex, toIndex, -1 do
	-- body
end

]]
@deprecated
function private.rpairs (array: {any})
	return private.iter_rpairs, array, #array + 1
end


function private.getiter (iterator: iter) : any
	return iterator == 'ipairs' and ipairs
		or iterator == 'pairs' and pairs
		or iterator == 'rpairs' and private.rpairs -- silenced
end


-- Merges two tables.
function private.merge <key1,val1,key2,val2> (self: tbl<key1,val1>, with: tbl<key2,val2>, iter: iter, clone: boolean)
	assert(self, private.err)
	assert(with, private.err)
	
	local r = clone and table.clone(self) or self
	for i,v in private.getiter(iter)(with) do
		local typeI, typeV = type(i), type(v)
		
		if typeI == 'number' then
			table.insert(r :: any, v)
		else
			r[i] = v
		end
	end
	
	return r :: typeof(self)&typeof(with)
end
-- Freeze the table and all nested tables.
function private.freezer (self: empt)
	private.recursive(self, "after", function(self: anytbl, gate) 
		table.freeze(self)
		return
	end)
end


-- Searches for a value and returns it's key.
function private.doSearchKeyForTable (self: anytbl, value: any)
	for i,v in pairs(self) do
		if value == v then
			return i
		end
	end
	return nil
end

-- Recursive search for value and return it's parent.
function private.DoGetKeyParent (self: {[any]: anytbl }, value: any) : any?
	for i,v in pairs(self) do
		if private.doSearchKeyForTable(v, value) then
			return i
		end
	end
	return nil
end

-- If tbl2 in tbl1, return tbl2.
function private.DoSearchAndEnterArray (self: {anytbl}, tbl2: anytbl) : anytbl?
	for i=1, #self do
		if self[i]==tbl2 then
			return tbl2
		end
	end
	return nil
end
-- Recursive search for key and return it's value.
function private.DoRecursiveSearchKey (self: anytbl, key: any)
	return private.recursive(self, "after", function(cur_tbl, cur_tbl_name): any
		return cur_tbl == key and cur_tbl or cur_tbl_name ==key and cur_tbl or cur_tbl[key] or nil
	end)
end
-- Recursive search for value and return it's index.
function private.DoRecursiveSearchValue (self: anytbl, value: any)
	return private.recursive(self, "after", function(cur_tbl, cur_tbl_name): any 
		for i,v in pairs(cur_tbl) do
			if v == value then
				return i
			end
		end
		return nil
	end)
end


local public = {}
public.rpairs = private.rpairs
public.EnterPoint = private.DoSearchAndEnterArray
public.Recursive = private.recursive
public.Flip = private.flipper
public.Merge = private.merge
public.DeepFreeze = private.freezer
public.GetKey = private.DoRecursiveSearchKey
public.GetValue = private.DoRecursiveSearchValue
public.ParentOfKey = private.DoGetKeyParent
public.IndexForValue = private.doSearchKeyForTable
public.DeepClone = private.copy
table.freeze(public)
table.freeze(private)

type empt = {}
type tbl<k,v> = {[k]:v}
type anytbl = {[any]:any}
type recursiveIter = 'after'|'before'
type iter = 'pairs'|'ipairs'|'rpairs'

return public