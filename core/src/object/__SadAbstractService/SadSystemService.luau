local main = require('./')

local private = {}
local class = {}; setmetatable(class,class);
local interface = {};

local HxSignal = main.Libs.Hexagon.Classes.HxSignal()
type SadSystemService = typeof(private.new({Name=''}))

type DefaultF = (deltaTime: number, NewCycle: boolean)->()
type Core = typeof(HxSignal.new(warn::DefaultF))
type Controller = {Core:Core,Count:number,Me:SadSystemService}

function private.new <T,Y> (Service: T & main.DefaultServiceNeedle<Y>)
	return main.__SadAbstractService_protected.NewChild(Service :: T,class)
end

private.show_dev = setmetatable({} ::{[SadSystemService]:boolean}, {__mode='k'})
private.task_map = setmetatable({}::{[SadSystemService]: Controller}, {__mode='k'})
private.task_list = setmetatable({} :: {Controller}, {__mode='v'})

private.task_self = setmetatable({} :: {[string]: Controller?}, {__mode='v'})

--[[
	@class SadSystemService
]]
function private:while_active_do ()
	local self = self :: SadSystemService;
	
	local Controller = private.task_map[self]
	if Controller then
		return Controller.Core:AddEvent()
	else
		local Core = HxSignal.new(warn::DefaultF)
		local Id = tostring(Core)
		Controller = {
			Core = Core;
			Count = 0;
			Me = self;
		}
		
		task.defer(function ()
			local Controller = private.task_self[Id]
			local delta = 0
			local teta = os.clock()
			local beta = teta
			
			while Controller do
				if #Controller.Core.Listeners < 1 then
					task.wait(Controller.Me.UpdateRate)
					continue
				end
				
				if not Controller.Me:IsActive() then
					Controller.Count = 0
					task.wait(Controller.Me.UpdateRate)
					continue
				end
				
				teta = os.clock()
				delta = teta - beta
				beta = teta
				
				task.spawn(function ()
					local Controller = private.task_self[Id]
					if Controller then
						Controller.Core:DoCall(delta, Controller.Count < 1)
						Controller.Count += 1
					end
				end)
				
				task.wait(Controller.Me.UpdateRate)
				Controller = private.task_self[Id]
			end
		end)
		
		private.task_map[self] = Controller
		private.task_self[Id] = Controller
		return Core:AddEvent()
	end
end

--[[
	@class SadSystemService
]]
function private:is_dev_active ()
	local self = self :: SadSystemService;
	return not not private.show_dev[self]
end

--[[
	
	@class SadSystemService
]]
function private:set_dev_active (State: boolean?)
	local self = self :: SadSystemService;
	private.show_dev[self]=State or false
end


--[[
	Учитывает фазовую логику как отдельные действия системы.
	Используется для отслеживания статуса обработки объектов, или этапа на котором упала система.
	
	@class SadSystemService
]]
function private:phased_log (PrintNoneJobNotifications: boolean?)
	local self = self :: SadSystemService;
	local phases : {boolean} = {}
	return {
		Insert = function (PhaseNumber: number, to: boolean)
			table.insert(phases, to)
		end,
		EndLog = function (ProcessedElement: unknown)
			table.freeze(phases)
			
			if self:IsLogActive() then
				local state : boolean?
				for i,v in phases do
					if v == false then
						state = false
						break
					elseif v == true then
						state = true
					else
						main.Mapping.Exception.TechicalException:Throw()
					end
				end
				
				if state == nil then
					if PrintNoneJobNotifications then
						self:PrintLog(string.format('Nothing to do for %s', tostring(ProcessedElement)))
					end		
				elseif state == false then
					self:PrintLog(string.format('Error for %s', tostring(ProcessedElement)))
				elseif state == true then
					self:PrintLog(string.format('Success for %s', tostring(ProcessedElement)))
				end
			end
			
--			warn(phases)
			
		end,
	}
end


class.__index = main.__SadAbstractService.class;
class.ClassName = main.Mapping.Class.SadSystemService;
class.Source = script;
class.DoWhileActive = private.while_active_do;
class.UpdateRate = 1/10;

class.DoPhaseLog = private.phased_log;
class.SetDevActive = private.set_dev_active;
class.IsDevActive = private.is_dev_active;

interface.class = class;
interface.new = private.new;

table.freeze(class)
table.freeze(private)
table.freeze(interface)

return main:expand({SadSystemService=interface})