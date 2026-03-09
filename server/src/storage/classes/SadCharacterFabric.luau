local main = require('../../');

local private = {};
local class = {};
local interface = {};



function private.new ()
	local this = main.new({

	}, class)
	
	return this
end




class.__index = main.Core.Classes.SadObject().class;
class.ClassName = main.Mapping.Class.SadCharacterFabric;
class.Source = script;
class.Enums = main.Mapping.Enum.CharacterController

class.Identity = '';
class


interface.class = class;
interface.new = private.new;

return main:expand({SadCharacterFabric = interface})