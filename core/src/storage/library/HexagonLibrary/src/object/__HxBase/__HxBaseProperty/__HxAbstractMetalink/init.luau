local main = require('./')

local private = {};
local class = {};
class.__index = main.__HxBaseProperty.class;
setmetatable(class,class);
local interface = {};
interface.class = class;


class.AddMethode = main.Abstract.SelfOverride; -- insert methodes to this object
class.RemMethode = main.Abstract.SelfOverride; -- remove methodes from this object
class.Metamethode = main.Abstract.ShouldOverrided; -- main function that calls methods
class.ClassName = main.ClassNames.HxAbstractMetalink;
class.Source = script;

return main:expand({__HxAbstractMetalink=interface})