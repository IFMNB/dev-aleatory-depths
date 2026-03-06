local main = require('./')

local private = {};
local class = {}; class.__index=main.Number.class; setmetatable(class,class);
local interface = {}; 

local HxEventCore = main.HxEventCore
local HxEvent = main.HxEvent

type HxNumberModifier = typeof(private.new())
type HXM_F = (HxNumberModifier: HxNumberModifier)->()
type HxEventCore = typeof(HxEventCore.new((nil::any)::HXM_F, class.ClassName))
type HxEvent = typeof(((nil::any)::HxEventCore):AddEvent())
type F = (origin: number, previous_modificated: number) -> number


--[[
	Creates new HxNumberModifier object.

	@class HxNumberModifier
	@return Instance (@P HxNumberModifier)
]]
function private.new (value: number?)
	local EventCore_Apply = HxEventCore.new(warn::HXM_F, 'apply')
	local EventCore_Push = HxEventCore.new(warn::HXM_F, 'push')
	local Event = EventCore_Apply:AddEvent()
	local Event2 = EventCore_Push:AddEvent()
	
	local this = main.new({Value=value::number}, class)
	this.OnModifiedEvent = Event;
	this.OnPushEvent = Event2;
	this.Modificators = {} :: typeof(class.Modificators);
	this.ApplyMod = main.Abstract.Wrap(nil,class.ApplyMod,function(...) 
		EventCore_Apply:DoCall(this)	
	end)
	this.PushMod = main.Abstract.Wrap(nil,class.PushMod,function(...) 
		EventCore_Push:DoCall(this)
	end)
	this.Push = main.Abstract.Wrap(nil,class.Push,function(...) 
		EventCore_Push:DoCall(this)
	end)
	
	return this
end
--[[
	Apply all modificators to this NumberObject. 

	Fires OnModifiedEvent.

	@class HxNumberModifier
	@return ()
]]
function private:ApplyMod ()
	local self = self :: HxNumberModifier
	local mods = self.Modificators
	local val = self.Value
	local prev = val
	for _, mod in mods do
		for _, m in mod do
			val += m(val, prev)
			assert(type(val)=='number', 'Modificator must return number')
			prev = val
		end
	end
	
	self:Push(val)
end
--[[
	Add new modificator to this HxNumberModifier.
	
	Notice the value that you get in modificator function is a result from formula:
		Origin += Modificator(Origin, Previous_Modificated)
	
	@class HxNumberModifier
	@return ()
	
	@usage
		HxNumberModifier:AddMod(1, function (Origin, Previous_Modificated) return origin * 32 + Previous_Modificated end)
		HxNumberModifier:ApplyMod()
		
		-- Now HxNumberModifier.Value =
]] 
function private:AddMod (InsertToPriority: number, mod: F)
	local self = self :: HxNumberModifier
	local pos = self.Modificators[InsertToPriority]
	if not pos then
		self.Modificators[InsertToPriority] = {};
		pos = self.Modificators[InsertToPriority]
	end
	
	table.insert(pos, mod);
end
	
--[[
	Find and remove modificator from this HxNumberModifier.
	
	@class HxNumberModifier
	@exception Modificator not found
	@return ()
]]
function private:RemoveMod (priority: number, mod: F)
	local self = self :: HxNumberModifier
	local pos = self.Modificators[priority]
	assert(pos, 'Priority list not found')
	local pos2 = table.find(pos, mod)
	assert(pos2, 'Modificator not found')
	
	table.remove(pos, pos2)
	if #pos == 0 then self.Modificators[priority] = nil end
end

--[[
	Pushes HxNumberModifier value to target value.	

	Fires OnPushEvent and OnModifiedEvent.
	
	@class HxNumberModifier
	@return ()
]]
function private:push (ToValue: number)
	local self = self :: HxNumberModifier
	self:Push(ToValue)
end

class.Value = 0 :: number
class.ClassName=main.ClassNames.HxNumberModifier
class.OnModifiedEvent = HxEvent.class;
class.OnPushEvent = HxEvent.class;

class.Modificators = {} :: {{(origin: number, previous: number)-> number }}

class.ApplyMod = private.ApplyMod
class.AddMod = private.AddMod
class.RemoveMod = private.RemoveMod
class.PushMod = private.push;

class.Source = script

interface.class = class;
interface.new = private.new

table.freeze(class)
table.freeze(private)
table.freeze(interface)
return main:expand({ModifiedNumber = interface});