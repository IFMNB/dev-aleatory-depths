local main = require('./__HxAbstractPrimetive')


local private = {};
local class = {}; class.__index=main.__HxBase.class; setmetatable(class,class);
local subclass = {}; subclass.__index=main.__HxBase.class; setmetatable(subclass,subclass);
local interface = {}; 

local shade = main.Shade.new()

type HxInstance = typeof(class)
type HxInstanceProperties = typeof(subclass)

function private.parentSet (self, key, value)
	if key == 'Parent' and type(value) == 'table' and value.IsA then
		local HxObject = value :: typeof(main.Objects.class)
		if HxObject:IsA('HxInstance') then
			local HxInstance = value :: HxInstance
			assert(not HxInstance[self.Name], 'equalent already exists inside this instance')
			HxInstance[self.Name]=self
		end
	end
end

private.holder = setmetatable({},{__mode='v'});

-- Creates a new instance. Do not use in other class constructors with generic types.
function private.new <data,class> (data:data,ClassName: class?)
	local this = main.new(data,class);
	local e0,c0 = main.Events.new(private.evname);
	local e1,c1 = main.Events.new(private.evname);
	
	do 
		local HxInstance : HxInstance = this :: any
		HxInstance.Changed = e0;
		HxInstance.Destroying=e1;
		HxInstance.Destroy = c0.Call;
		HxInstance.HxUniqueId = tostring(newproxy());
		HxInstance.ClassName = ClassName :: class;
		HxInstance.Name = HxInstance.HxUniqueId..HxInstance.ClassName
	end
	
	e1:Once(function(...) return private.destroy(this, ...) end);
	local MetalinkCreator = main.MetalinkCreator.new(); MetalinkCreator:AddMethode(rawset):AddMethode(private.parentSet):AddMethode(c0.Call);
	assert(getmetatable(this::any),'loss of metatable').__newindex = MetalinkCreator.Metamethode;
	table.insert(private.holder,this)
	
	local HxInstance : setmetatable<data, {
		__index: setmetatable<{ClassName: class}, {__index: typeof(class)}>,
		__newindex: typeof(MetalinkCreator.Metamethode)}> = this :: any;
	
	local properties = main.new({
		MetalinkCreator = MetalinkCreator,
		HxInstance = HxInstance,
		Identity = nil -- replace if instance has been replicated
	}, subclass)
	
	return HxInstance, properties
end

-- Applies a tag to the instance.
function private:SetTag (Tag: string)
	local self = self :: HxInstance
	local this = shade:Get(self)
	if not table.find(this, Tag) then
		table.insert(this, Tag)
	end
end
-- Removes a tag from the instance.
function private:RemoveTag (Tag: string)
	local self = self :: HxInstance
	local this = shade:Get(self)
	local index = table.find(this, Tag)
	if index then
		table.remove(this, index)
	end
end

-- Check whether the instance has a given tag.
function private:GetTag (Tag: string) : boolean
	local self = self :: HxInstance
	local this = shade:Get(self)
	return not not table.find(this, Tag)
end
-- Gets an array of all tags applied to the instance.
function private:GetTags ()
	return shade:Get(self::HxInstance)
end
-- Returns a list of all instances tagged with the given tag.
function private.getTaggedBy (Tag: string)
	local list = {} :: {HxInstance}
	for i,v in shade.Stored do
		if table.find(v, Tag) then
			table.insert(list, i)
		end
	end
	return list
end

function private.noParentSet (self, i,n)
	assert(i ~= 'Parent', 'cannot set Parent property')
end

function private.destroy (self)
	local self = self :: HxInstance
	local this = assert(table.find(private.holder,self), 'HxAbstractInstance is already destroyed')
	local meta = assert(getmetatable(self), 'cannot get metatable to destroy it')
	local HxMetalinkCreator = assert(main.MetalinkCreator.get(meta.__newindex::any), 'cannot get HxMetalinkCreator')
	self.Parent = nil
	HxMetalinkCreator:RemMethode(private.parentSet)
	HxMetalinkCreator:AddMethode(private.noParentSet)
	table.remove(private.holder, table.find(private.holder,self))
	for i,v in self do
		if type(v) == 'table' then
			local HxObject = v :: typeof(main.Objects.class)
			if HxObject.IsA and HxObject:IsA('HxAbstractInstance') then
				local HxAbstractInstance = v :: HxInstance
				HxAbstractInstance:Destroy()
				self[i]=nil
			end
		end
	end
end
-- Lettin you to control some class-private behaviours of the instance.
function private:sub_unset (ability: 'set_parent', to: boolean)
	local self = self :: HxInstanceProperties
	if ability == 'set_parent' then
		if to then
			self.MetalinkCreator:RemMethode(private.noParentSet)
			self.MetalinkCreator:AddMethode(private.parentSet)
		else
			self.MetalinkCreator:RemMethode(private.parentSet)
			self.MetalinkCreator:AddMethode(private.noParentSet)
		end
	end
end

private.evname = 'HxInstanceEvent'::'HxInstanceEvent';
class.HxUniqueId = (nil::any) :: string;
class.RemoveTag = private.RemoveTag;
class.AddTag = private.SetTag;
class.HasTag = private.GetTag;
class.GetTags = private.GetTags;
class.ClassName = main.ClassNames.HxInstance;
class.Parent = nil :: HxInstance|nil;
class.Source=script;
class.Changed, private.HxEventType = main.Events.new(private.evname);
class.Name = class.ClassName :: string;
class.Destroy = private.HxEventType.Call :: typeof(function (self) end);
class.Destroying = class.Changed;

subclass.ClassName = main.ClassNames.HxInstanceProperties;
subclass.Source = script;
subclass.MetalinkCreator = main.MetalinkCreator.class;
subclass.HxInstance = class :: HxInstance;
subclass.Identity = nil :: string?;
subclass.Declare = private.sub_unset;

interface.class=class;
interface.subclass = subclass;
interface.tagged = private.getTaggedBy;
interface.new = private.new;


table.freeze(class);
table.freeze(private);
table.freeze(interface);
return main:expand({
	HxInstance = interface,
	NumberObject = require('./__HxAbstractPrimetive/number'),
	StringObject = require('./__HxAbstractPrimetive/string')
});