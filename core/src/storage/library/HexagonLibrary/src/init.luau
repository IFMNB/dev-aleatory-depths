local root = {}

root.ClassNames = require('@self/map')
root.Abstract = require('@self/protected/__abstract')
root.Async = require('@self/protected/__async')

--[[
	Regarding the alignment of class names and values in the hierarchy.
		The base class does not guarantee anything except that its signature is respected by descendants.
		The abstract class ensures that all its descendants implement all the methods and properties that it implements.
		The interface class ensures that all of its descendants fit the context and contract of the role.
		Class - specific implementation

	The prefixes Hx, Ecs, etc. indicate the semantic role and belonging of a class to a group of goals.
]]

--[[
	Used for creating new objects.

	@p1 - data for the new object.
	@p2 - class of the new object.


	About .new() and where it can exists:
		Every time you access the constructor of a class, you pass in a certain state or data inside a specific function without a class argument.
		This is the constructor of the class.
		Using this function in abstract classes creates a template for the entire family of descendants of this abstract class.
	
	About class __index uses.
		Inside every class you should implement a __index metatable, that will be used for getting values from a table.
		This __index should refers to the class that you want to use for getting values.
		If you want to create an object of a class, you should use class constructor or this function wtih target class as second argument.
		
	
]]
function root.new <data, class> (data: data, class: class)
	local meta = getmetatable(data)
	if meta then assert(type(meta)=='table','data have locked metatable') end
	return setmetatable(table.clone(data),{__index=class})
end
--[[
	Used for self-class expansion, based on the class

	@p1 - class that you want to expand on target class.
	
	About class sematincs: 
		Each class is built as a module that returns an interface, and inside the interface are the public fields of the class.
		The class contains an __index that points to its parent class, and it has a metatable for itself.
		Inside the class module, there is a private table that contains everything that the class user does not need.
		 
	About class interface:
		The class interface provides the user with the public properties of the class.
		The class interface also provides a .new() constructor.
		If necessary, there may also be a .get() method for retrieving existing instances.
		The .new() constructor itself is almost always required to have optional parameters.
 
	About class properties:
		A class has inherited properties within it.
		It also provides abstract properties to the user that are not implemented in the class but are implemented in the object.
		Class objects are required to inherit all properties without adding any new ones.
		Objects, if that declared on the class, can have their own functions and methods.
	 
	About abstract classes:
		A class of this type is only intended to declare semantics and cannot be used to create objects.
		There should be almost no logic inside such a class.
		If the inheritors of this class have specific behavior, then such a class can have a constructor.
		A constructor of this kind is called a "template."
		Template constructors are used by the inheriting classes. Mainly, for the final creation of an object.
		The .new() constructor of a non-abstract class will never require a class field for itself.
		
]]
function root:expand <t0> (expansion: t0) 
	local r0 = {__index=self}
	local r1 = setmetatable(table.clone(expansion),r0)
	table.freeze(r0::any)
	table.freeze(r1::any)
	return r1
end

return root