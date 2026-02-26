local main = require('./');

local private = {};
local class = {}; setmetatable(class,class);
local interface = {};

type IHxCollection = typeof(class)

function private:set (index: string, value: any)
	local self = self :: IHxCollection;
	assert(self.Value, 'doesnt have value')
	assert(self.Value[index]==nil, 'override is not allowed')
	self.Value[index] = value
end

function private:get (index: string) : any
	local self = self :: IHxCollection;
	assert(self.Value, 'doesnt have value')
	assert(self.Value[index]~=nil, 'not have this value')
	return self.Value[index]
end

class.__index=main.__HxBaseCollection.class;
class.ClassName = main.ClassNames.IHxMap;
class.Source = script;
class.Value = nil :: {[string]: any}?;
class.Get = private.get;
class.Set = private.set;

interface.class = class;

return main:expand({_IHxMap=interface})