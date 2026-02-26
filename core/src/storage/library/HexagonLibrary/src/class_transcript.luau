local src = require('./')
local object = require('./object').Objects

local private = {}
local interface = {}

private.synchro = {}

type translated = typeof(private.translate({}::any))

function private.translate <who> (element: who | any)
	local result = {}
	local is_table = assert(type(element)=='table', 'isnt a table, reflect')
	local is_object = object.class.IsA(element, 'HxObject')
	
	if is_object then
		if element.Replicatable then
			result.Source = element.Source
			result.ClassName = element.ClassName
			result.Replica = element :: who
			return result
		else
			warn('Cant replicate objects without Replicatable set to true. Still you can replicate this object as a table.')
			return element
		end
	end
	
	warn('This is not a HxObject or instance that inherited from HxObject. Still you can replicate this.')
	return element
end

type object_Result = typeof(object.new({}::{[any]:any}))
type F = (...unknown)->object_Result

function private.transform (translated: translated | any)
	local result
	local is_module = game.IsA(translated.Source, 'ModuleScript')
	
	if is_module then
		local module = require(translated.Source) :: {new: F?, get: F?, class: typeof(object.class) & {[any]: any}}
		if module.new then
			result = module.new()
			for i,v in translated.Replica :: {[any]:any} do
				result[i]=v
			end
			
		elseif module.get then
			result = module.get()
			for i,v in translated.Replica :: {[any]:any} do
				result[i]=v
			end
			
		else
			error('ModuleScript has no new or get function.')
		end
	end
	
	return result
end

interface.Translate = private.translate
interface.Transform = private.transform

return interface