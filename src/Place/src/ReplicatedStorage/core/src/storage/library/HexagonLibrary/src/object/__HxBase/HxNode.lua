local main = require('./');

local private = {};
local class = {}; setmetatable(class,class);
local interface = {};

type HxNode = typeof(private.new());

function private.new <Y,T,U> (value: Y?, BackNode: HxNode?, NextNode: HxNode?)
	return main.new({
		Value = value :: Y,
		BackNode = BackNode,
		NextNode = NextNode,
	}, class)
end

--[[
	Removes the node from the line.
	
	@class HxNode
]]
function private:remove_from_line ()
	local self = self :: HxNode;

	if self.BackNode then
		if self.IsA(self.BackNode, 'HxNode') then
			self.BackNode.NextNode = self.NextNode
		end
	end
	
	if self.NextNode then
		if self.IsA(self.NextNode, 'HxNode') then
			self.NextNode.BackNode = self.BackNode
		end
	end
	
	self.BackNode = nil;
	self.NextNode = nil;
end

class.__index=main.__HxBase.class;
class.Classindex=main.ClassNames.HxNode;
class.Source=script;

class.BackNode = nil :: HxNode?;
class.NextNode = nil :: HxNode?;
class.Value = nil :: {[any]:any}?;
class.DoRemove = private.remove_from_line;

interface.class = class;
interface.new = private.new;

return main:expand({HxNode=interface})