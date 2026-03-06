local LOC_SV = game:GetService('LocalizationService')

local main = require('./')

local private = {};
local class = {}; class.__index=main.String.class; setmetatable(class,class);
local interface = {}; interface.class = class;

type TransString = typeof(private.new(Instance.new('Player')))

private.translators = setmetatable({}::{[TransString]: Translator}, {__mode='kvs'})

--[[
	Returns TransString object with translator for player.
	
	This constructor should be wrapped in pcall

	@class HxTranslationString
	@return Instance (@P TransString)
]]
function private.new <data> (player: Player, value: string?)
	local tstring = main.new({Value=value::string},class)
	local translator = LOC_SV:GetTranslatorForPlayerAsync(player)
	private.translators[tstring]=translator
	return tstring
end

--[[
	Translates string to player language.

	@class HxTranslationString
	@return string
]]
function private:Translate ()
	local self = self :: TransString
	local translator = private.translators[self]
	if string.len(self.Value) < 2 then
		warn(string.format('Value %q for %s is too short for translation, result will be the same', self.Value, self.ClassName))
		return self.Value
	end
	self.Value = translator:Translate(game, self.Value)
	return self.Value
end

class.Source = script
class.ClassName = main.ClassNames.HxTranslationString
class.Translate = private.Translate 
interface.new = private.new

table.freeze(class)
table.freeze(private)
table.freeze(interface)
return main:expand({TString=interface})