local main = require('./')

local Hx = main.Libs.Hexagon
local HxEventCore = Hx.Classes.HxEventCore()

local private = {}
local class = {}; setmetatable(class,class);
local interface = {};

local PhysicsService = game:GetService('PhysicsService')

type SadPhysicGroup <T=string> = typeof(interface.new(nil::T))

function private.new (name: string)
	type DF = (Element: BasePart)->()
	local Core1 = HxEventCore.new(warn::DF);
	local Core2 = HxEventCore.new(warn::DF);
	
	local Event1 = Core1:AddEvent();
	local Event2 = Core2:AddEvent();
	
	local this = main.new({
		Name = name;
		Elements = {} :: typeof(class.Elements);
		
		Add = main.Abstract.Wrap(nil,class.Add,function(self,a0) Core1:DoCall(a0) end);
		Rem = main.Abstract.Wrap(nil,class.Rem,function(self,a0) Core2:DoCall(a0) end);
		
		
		OnElementAddedEvent = Event1;
		OnElementRemovedEvent = Event2;
	}, class)

	return this
end

function private:set_collision_between_groups (group: SadPhysicGroup, to: boolean?)
	local self = self :: SadPhysicGroup;
	PhysicsService:CollisionGroupSetCollidable(self.Name, group.Name, to or false)
end

function private:assign_element (Element: BasePart)
	local self = self :: SadPhysicGroup;
	
	Element.CollisionGroup = self.Name
	table.insert(self.Elements, Element)
	local con : RBXScriptConnection
	con = Element:GetPropertyChangedSignal('CollisionGroup'):Connect(function(...) 
		if Element.CollisionGroup ~= self.Name then
			con:Disconnect()
			local pos = main.Mapping.Exception.CodeException:Assert(table.find(self.Elements, Element))
			table.remove(self.Elements, pos)
		end
	end)
end

function private:get_all_models ()
	local self = self :: SadPhysicGroup;
	local this = {} :: {Model}
	for i,v in self.Elements do
		local Model = v:FindFirstAncestorOfClass('Model')
		if Model then
			if table.find(this, Model) then continue end
			table.insert(this, Model)
		end
	end
	return this
end

function private:remove_element (Element: BasePart)
	local self = self :: SadPhysicGroup;
	main.Mapping.Exception.CodeException:Assert(Element.CollisionGroup == self.Name)
	Element.CollisionGroup = 'Default'
end

class.__index=main._ISadGroup.class;
class.ClassName=main.Mapping.Class.SadPhysicGroup;
class.Source=script;
class.Name = '';
class.Elements = {} :: {BasePart};
class.Add = private.assign_element;
class.Rem = private.remove_element;
class.SetCollisionBetweenGroups = private.set_collision_between_groups;
class.GetAllModels = private.get_all_models;

interface.class=class;
interface.new=private.new;

return main:expand({SadPhysicGroup=interface})