--!nolint DeprecatedApi
--!native

local src = require('../../../../interface/src_base')
local libs = src:Libs()
local LarsenBufferize = require('./TableToBufferFORK')
local Mapping = src:Mapping()
local Source = src.Source()

local ISadObject = src.Classes.SadObject()
local SadObject = ISadObject.class

type SadObject = typeof(SadObject)

local private = {};
local interface = {};

private.safe = table.freeze({
	LocalEnum = src.Classes.HxLocalEnum().class.Source;
	RuntimeException = src.Classes.HxRuntimeException().class.Source;
});
private.safestrigns = {} :: {[string]: string}; 
for i,v in (private::any)[('safe'::any)] do
	private.safestrigns[i] = libs.RbxUtility.GetPath(v)
end;

function private.BufferizeTransport (...: any) : buffer
	local payload = {...}
	local count = #payload
	local result
	
	for i,v in payload do
		if typeof(v) == 'table' then
			if SadObject.IsA(v, 'HxObject') then
				local object = v :: SadObject
				v['@S'] = Mapping.Exception.CodeException:Assert(object:GetSourcePath())
				v['@C'] = object:GetClass()
			end
		end
	end
	
	result = LarsenBufferize.Table.convert(payload :: any)
	
	return result
end

function private.UnbufferizeTransport (buffer: buffer) : any
	local this = LarsenBufferize.Table.read(buffer) :: {any};
	local res = {} :: {[any]: any}
	
	for i,v in this do
		if typeof(v) == 'table' then
			if v['@S'] then
				Mapping.Exception.SafetyException:Assert(v['@C'])
				local state = false
				for i,s in private.safestrigns do
					if s == v['@S'] then
						state = true
						break
					end
				end
				
				Mapping.Exception.SafetyException:Assert(state)
				
				local state, module : {[string]: {class: {ClassName: string, [any]:any}}} = pcall(require, v['@S'] :: any) 
				Mapping.Exception.SafetyException:Assert(state)
				Mapping.Exception.SafetyException:Assert(next(module))
				local class
				for i,vC in module do
					if vC.class.ClassName == v['@C'] then
						class = vC.class
					end
				end
				Mapping.Exception.SafetyException:Assert(class)
				
				v['@S'] = nil
				v['@C'] = nil
				
				res[i] = Source.new(v, class)
			else
				res[i] = v
			end
		else
			res[i] = v
		end
	end
	
	return res
end


interface.Write = private.BufferizeTransport;
interface.Read = private.UnbufferizeTransport;


interface.SafeToLoad = private.safe;

table.freeze(interface)

return interface;