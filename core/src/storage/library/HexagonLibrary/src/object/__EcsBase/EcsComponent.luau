local main = require('./');

local private = {};
local class = {};
class.__index=main.__EcsBase.class;
setmetatable(class,class);
local interface = {};

type function set_name (default: type, name: type)
	return name:is('singleton') and name or default
end

function private.new <value, name> (name: name?, data: value?)
	return main.new({
		Value=data,
		Name= (name or class.Name) :: set_name<typeof(class.Name),name>
	},class)
end

class.Value = nil :: unknown;
class.Name = '';
class.Replicatable = true :: true;
class.ClassName = main.ClassNames.EcsComponent;
class.Source = script;


interface.new = private.new;
interface.class = class;

table.freeze(class)
table.freeze(interface)
table.freeze(private)

return main:expand({EcsComponent = interface})