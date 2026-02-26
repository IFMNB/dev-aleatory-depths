-- # core src

local Library = require('@self/interface/src_library'):Libs()
local Hexagon_Source = Library.Hexagon:Source()
local src = {}
setmetatable(src, {__index=Hexagon_Source})

src.Libs = Library
src.Mapping = require('@self/mapping')
src.Abstract = setmetatable({}, {__index=Hexagon_Source.Abstract})

--[[
	Оборачивает выполнение одной функции в каллбек для другой.
	Ранее самостоятельно выстраивал тип.
	
	@class SadSource
	@private
	@side all
	@return Function
]]
src.Abstract.Wrap = function <T,F, R, U...> (Callback: (...any)->(), Call: F&((T, ...R)->U...))
	return (function (...: R)
		Callback(...)
		return Call(...)
	end) :: F
end

return src