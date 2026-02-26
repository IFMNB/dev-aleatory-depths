local main = require('./');


local private = {};
local class = {};
class.__index=main.Objects.class;
setmetatable(class,class);
local interface = {};
interface.class = class;


class.ClassName = main.ClassNames.EcsBase;
class.Source = script;

return main:expand({__EcsBase = interface, I_Base=require('../interface/src_base')})