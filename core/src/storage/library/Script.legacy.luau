local hx = require('./HexagonLibrary')

local a = hx.Classes.HxEventCore().new(function (b:number) return end)
local b = hx.Classes.HxEventCore().new(function (a:string) return end)

local a0 = a:AddEvent()

type HxEventA = typeof(a:AddEvent());
type HxEventB = typeof(b:AddEvent());

local d = hx.Classes.HxEvent().class
local c = setmetatable({DefaultFunction = (nil)::any}, {__index = d})

type HxEvent = typeof(c)

local t : HxEvent = a0 :: HxEventA