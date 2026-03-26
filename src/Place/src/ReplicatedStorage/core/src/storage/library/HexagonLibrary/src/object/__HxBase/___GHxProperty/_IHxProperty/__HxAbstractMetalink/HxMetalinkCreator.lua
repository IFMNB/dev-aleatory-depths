local main = require('./')

local private = {};
local class = {};
class.__index=main.__HxAbstractMetalink.class;
setmetatable(class,class);
local interface = {};
interface.class = class;

type HxMetalinkCreator = typeof(class)
type f = (self: any, i: any, n: any, o: any) -> ()|any

private.funcs=setmetatable({}::{[typeof(class.Metamethode)]:HxMetalinkCreator?},{__mode="ks"})

function private.new ()
	local links = {} :: {f}
	local this = main.new({
		Links=links,
		Metamethode = function (self:any, i:any, n:any)
			local o = self[i]
			for i,v in links do
				v(self,i,n,o)
			end
		end,
	},class)
	private.funcs[this.Metamethode]=this
	
	return this
end

function private.get (metamethode: typeof(class.Metamethode))
	return private.funcs[metamethode]
end

function private:generate_for ()
	local this = self :: HxMetalinkCreator
	return function (self:any, i:any, n:any)
		local o = self[i]
		for i,v in this.Links do
			v(self,i,n,o)
		end
	end
end

-- Given methode will be used in next call of the object.
function private:new_methode (methode: f)
	local self = self :: HxMetalinkCreator
	table.insert(self.Links,methode)
	
	return self
end

-- Given methode will be removed if he exists. If methode has a copy then only that copy will be removed.
function private:remove_methode (methode: f)
	local self = self :: HxMetalinkCreator
	local md = table.find(self.Links,methode)
	if md then table.remove(self.Links,md) end
	
	return self
end

class.ClassName = main.ClassNames.HxMetalinkCreator;
class.Source = script;
class.Links = {};
class.AddMethode = private.new_methode;
class.RemMethode = private.remove_methode;

interface.new = private.new;
interface.get = private.get;

table.freeze(class)
table.freeze(interface)
table.freeze(private)
return main:expand({HxMetalinkCreator = interface})