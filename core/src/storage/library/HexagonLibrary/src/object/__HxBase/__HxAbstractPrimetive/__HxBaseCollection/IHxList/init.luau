local main = require('./');

local private = {};
local class = {}; setmetatable(class,class);
local interface = {};

type IHxArray = typeof(class)

function private:get (index: number) : any
	local self = self :: IHxArray;
	assert(self.Value, 'doesnt have value')
	assert(self.Value[index]~=nil, 'not have this value')
	return self.Value[index]
end

function private:insert (index: number, to: any)
	local self = self :: IHxArray;
	assert(self.Value, 'doesnt have value')
	
	table.insert(self.Value, index, to)
end

function private:set (index: any, to: any)
	local self = self :: IHxArray;
	assert(self.Value, 'doesnt have value')
	assert(self.Value[index]== nil, 'override is not allowed')
	
	self.Value[index] = to
end

function private:quick_fix ()
	local self = self :: IHxArray;
	assert(self.Value, 'doesnt have value')
	
	local fixed = {}
	local should = false
	for i,v in self.Value do
		if v == nil then
			should = true
		else
			table.insert(fixed, v)
		end
	end
	
	if should then
		table.clear(self.Value)
		table.move(fixed, 1, #fixed, 1, self.Value)
	end
end

function private:sort_quadric ()
	local self = self :: IHxArray;
	assert(self.Value, 'doesnt have value')
	
	private.quick_fix(self);
	for i=1, #self.Value do
		for j=1, #self.Value do
			if self.Value[i] < self.Value[j] then
				self.Value[i], self.Value[j] = self.Value[j], self.Value[i]
			end
		end
	end
end

function private:sort_bubble ()
	local self = self :: IHxArray;
	assert(self.Value, 'doesnt have value')
	
	private.quick_fix(self);
	local done = false
	while true do
		done = false
		for i=1, #self.Value do
			if self.Value[i] > self.Value[i+1] then
				self.Value[i], self.Value[i+1] = self.Value[i+1], self.Value[i]
				done = true	
			end
		end
		if not done then break end
	end
end

function private:sort_quick ()
	local self = self :: IHxArray;
	assert(self.Value, 'doesnt have value')
	
	private.quick_fix(self);
	table.sort(self.Value)
end

function private:sort_selective ()
	local self = self :: IHxArray;
	assert(self.Value, 'doesnt have value')
	
	private.quick_fix(self);
	
	local lulz = {}
	local j, n = 0, nil
	
	while true do
		for i=1, #self.Value do
			if self.Value[i] > n then
				j = i
				n = self.Value[i]
			end
		end
		
		table.remove(self.Value,j)
		if n == nil then break end
		table.insert(lulz, n)
		j,n=0,nil
	end	
	
	table.clear(self.Value)
	for i=#lulz, 1, -1 do
		table.insert(self.Value, lulz[i])
	end
end

class.__index=main.__HxBaseCollection.class;
class.ClassName = main.ClassNames.IHxList;
class.Source = script;
class.Value = nil :: {any}?;
class.Get = private.get;
class.Set = private.set;
class.Insert = private.insert;

class.SortQuadric = private.sort_quadric;
class.SortBubble = private.sort_bubble;
class.SortQuick = private.sort_quick;
class.SortSelective = private.sort_selective;

interface.class = class;

return main:expand({_IHxList=interface})