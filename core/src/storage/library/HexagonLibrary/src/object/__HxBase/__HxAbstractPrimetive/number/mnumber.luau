local main = require('./')

local private = {};
local class = {}; class.__index=main.Number.class; setmetatable(class,class);
local interface = {}; 

local shade = main.Shade.new()

private.evname = 'ModNumberEvent'::'ModNumberEvent'



type NumberModifierObject = typeof(private.new())

function private.new (value: number?)
	local ev0, c0 = main.Events.new(private.evname)
	
	local this =  main.__HxAbstractPrimetive.new(value or class.Value, class)
	this.OnModifiedEvent = ev0 :: typeof(class.OnModifiedEvent)
	this.Modificators = {} :: typeof(class.Modificators)
	shade:Set(this, c0)
	
	return this
end
-- Apply all modificators to this NumberObject. Sets this NumberObject value to result of modification.
function private:ApplyMod ()
	local self = self :: NumberModifierObject
	local mods = self.Modificators
	local val = self.Value
	local prev = val
	for _, mod in mods do
		for _, m in mod do
			val = m(val, prev)
			assert(type(val)=='number', 'Modificator must return number')
			prev = val
		end
	end
	
	self.Value = val
	local EventProperties = shade:Get(self) :: typeof(main.Events.subclass2)
	EventProperties.Call(self.Value)
	return self
end
-- Add new modificator to this NumberObject. 
function private:AddMod (priority: number, mod: (origin: number, previous: number)-> number)
	local self = self :: NumberModifierObject
	local pos = self.Modificators[priority]
	if not pos then self.Modificators[priority] = {}; pos = self.Modificators[priority] end
	
	table.insert(pos, mod)
	return self
end
-- Remove modificator from this NumberObject. This methode removes first found modificator with given priority and function.
function private:RemoveMod (priority: number, mod: (origin: number, previous: number)-> number)
	local self = self :: NumberModifierObject
	local pos = self.Modificators[priority]
	assert(pos, 'Priority list not found')
	local pos2 = table.find(pos, mod)
	assert(pos2, 'Modificator not found')
	
	table.remove(pos, pos2)
	if #pos == 0 then self.Modificators[priority] = nil end
	
	return self
end

class.Value = 0 :: number
class.ClassName=main.ClassNames.HxNumberModifier
class.OnModifiedEvent = (nil::never) :: typeof(main.Events.new(private.evname));
class.Modificators = {} :: {{(origin: number, previous: number)-> number }}
class.ApplyMod = private.ApplyMod
class.AddMod = private.AddMod
class.RemoveMod = private.RemoveMod
class.Source = script

interface.class = class;
interface.new = private.new

local a = interface.new()

table.freeze(class)
table.freeze(private)
table.freeze(interface)
return main:expand({ModifiedNumber = interface});