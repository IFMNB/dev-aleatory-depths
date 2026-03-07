local main = require('./')

local http = game:GetService('HttpService')

local private = {};
local class = {};setmetatable(class,class)
local interface = {};

type INet = typeof(class)



function private:jsonEncode ()
	local self = self :: INet;
	return http:JSONEncode(self)
end

function private:isJsonMine (JSON: string)
	local self = self :: INet;
	return JSON == self:JSONEncode()
end

class.__index=main.Objects.class;
class.Source=script;
class.ClassName = main.ClassNames.INet;
class.IsReplicatable = true :: true;

class.JSONEncode = private.jsonEncode;
class.IsMyJSON = private.isJsonMine;

interface.class=class;

table.freeze(class)
table.freeze(private)
table.freeze(interface)
return main:expand({_INet=interface})