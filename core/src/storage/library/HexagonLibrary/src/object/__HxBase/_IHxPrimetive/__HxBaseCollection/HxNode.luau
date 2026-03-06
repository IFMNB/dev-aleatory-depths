local main = require('./');

local private = {};
local class = {}; setmetatable(class,class);
local interface = {};

type HxNode = typeof(class);

function private.new <Y,T,U> (value: Y?, BackNode: T?, NextNode: U?)
	return main.new({
		Value = value :: Y,
		BackNode = BackNode :: T,
		NextNode = NextNode :: U,
	}, class)
end

function private:Set (index: any, to: any)
	local self = self :: HxNode;
	assert(self.Value, 'doesnt have value')
	assert(self.Value[index]==nil, 'override is not allowed')
	
	self.Value[index] = to
end

function private:Get (index: any)
	local self = self :: HxNode;
	assert(self.Value , 'doesnt have value')
	assert(self.Value[index]~=nil, 'not have this value')
	return self.Value[index]
end

class.__index=main.__HxBaseCollection.class;
class.Classindex=main.ClassNames.HxNode;
class.Source=script;
class.BackNode = nil :: HxNode?;
class.NextNode = nil :: HxNode?;
class.Value = nil :: {[any]:any}?;
class.Set = private.Set;
class.Get = private.Get;

interface.class = class;
interface.new = private.new;

return main:expand({HxNode=interface})