local main = require('./');

local private = {};
local class = {}; setmetatable(class,class);
local interface = {};

type HxAbstractTable = typeof(class)

function private:get_count ()
	local self = self :: HxAbstractTable;
	assert(self.Value, 'Value is nil')
	
	local count = 0
	for i,v in self.Value do
		count+=1
	end
	
	return count
end

function private:clear ()
	local self = self :: HxAbstractTable;
	assert(self.Value, 'Value is nil')
	
	for i,v in self.Value do
		self.Value[i] = nil
	end
end

function private:contains_value (value: any)
	local self = self :: HxAbstractTable;
	assert(self.Value, 'Value is nil')
	
	for i,v in self.Value do
		if v == value then
			return true
		end
	end
	
	return false
end

function private:contains_index (index: any)
	local self = self :: HxAbstractTable;
	assert(self.Value, 'Value is nil')
	
	if self.Value[index] then
		return true
	else
		return false
	end
end

function private:has_type (typename: string)
	local self = self :: HxAbstractTable;
	assert(self.Value, 'Value is nil')
	
	for i,v in self.Value do
		if typeof(v) == typename then
			return true
		end
	end
	
	return false
end

function private:has_key_type (typename: string)
	local self = self :: HxAbstractTable;
	assert(self.Value, 'Value is nil')
	
	for i,v in self.Value do
		if typeof(i) == typename then
			return true
		end
	end
	
	return false
end

function private:collect_value (value: any)
	local self = self :: HxAbstractTable;
	assert(self.Value, 'Value is nil')
	
	local new = {}
	
	for i,v in self.Value do
		if v == value then
			new[i] = v
		end
	end
	
	return new
end

function private:collect_index (index: any)
	local self = self :: HxAbstractTable;
	assert(self.Value, 'Value is nil')
	
	local new = {}
	
	for i,v in self.Value do
		if i == index then
			new[i] = v
		end
	end
	
	return new
end

class.__index = main.__HxAbstractPrimetive.class;
class.ClassName = main.ClassNames.HxBaseCollection;
class.Source = script;


class.Value = nil :: {[any]:any}?;

class.Count = private.get_count;
class.Clear = private.clear;

class.ContainsValue = private.contains_value;
class.ContainsIndex = private.contains_index;
class.HasVType = private.has_type;
class.HasIType = private.has_key_type;
class.CollectValue = private.collect_value;
class.CollectIndex = private.collect_index;

class.Set = main.Abstract.SelfOverride;
class.Get = main.Abstract.SelfOverride;

interface.class = class;


table.freeze(private)
table.freeze(class)
table.freeze(interface)
return main:expand({__HxBaseCollection=interface})