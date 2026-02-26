local main = require('./')

local private = {};
local class = {};
class.__index=main.HxInstance.class;
setmetatable(class,class);
local interface = {};
interface.class = class

type HxAbstractParallel = typeof(class)

class.Do = main.Abstract.SelfOverride
class.DoParallel = main.Abstract.SelfOverride
class.WaitResult = main.Abstract.SelfOverride

class.ClassName = main.ClassNames.HxBaseParallel
class.Source=script
class.Result = nil :: unknown|'*error*'
class.Worker = nil :: Actor?
class.Active = false

return main:expand({__HxBaseParallel = interface})