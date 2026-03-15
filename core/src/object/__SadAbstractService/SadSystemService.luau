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

--[[
	Подключается к общему обработчику собитий.
	
	Данный обработчик вызывает подключенных слушателей N раз в кадр.

	@class SadSystemService
]]
function private:while_active_do ()
	local self = self :: SadSystemService;
	
	local Controller = private.task_map[self]
	local Core : Core = Controller and Controller.Core
	if not Core then
		Core = HxSignal.new(warn::DefaultF)
		Controller = {Core=Core,Count=0,Me=self}
		private.task_map[self] = Controller
		table.insert(private.task_list, Controller)
	end
	
	return Core:AddEvent()
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


local task_reactor = nil :: thread?
--[[
	Scheduler для активности систем

]]
function private.task_list_react ()
	if task_reactor then
		task.cancel(task_reactor)
		task_reactor =  nil
	end
	
	task_reactor = task.spawn(function ()
		local T = class.UpdateRate;
		local delta = 0
		local beta = tick()
		
		while true do
			if #private.task_list <= 0 then task.wait(T) continue end
			
			delta = tick() - beta
			beta = tick()
			
			for i,v in private.task_list do
				if not v.Me:IsActive() then
					v.Count = 0
					continue
				end
				
				task.defer(function ()
					v.Core:DoCall(delta, v.Count <= 0)
				end)
				
				v.Count+=1
			end
			
			task.wait(T)
		end
		
		main.Mapping.Exception.TechicalException:Throw()
	end)
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
class.UpdateRate = 1/2;

class.DoPhaseLog = private.phased_log;
class.SetDevActive = private.set_dev_active;
class.IsDevActive = private.is_dev_active;

interface.class = class;
interface.new = private.new;

table.freeze(class)
table.freeze(private)
table.freeze(interface)
private.task_list_react()

return main:expand({SadSystemService=interface})