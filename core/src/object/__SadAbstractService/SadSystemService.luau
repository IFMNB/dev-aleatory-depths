local main = require('./')

local private = {}
local class = {}; setmetatable(class,class);
local interface = {};

local HxEventCore = main.Libs.Hexagon.Classes.HxEventCore()
type SadSystemService = typeof(private.new({Name=''}))

type DefaultF = (deltaTime: number, NewCycle: boolean)->()
type Core = typeof(HxEventCore.new(warn::DefaultF))
type Controller = {Core:Core,Count:number,Me:SadSystemService}

function private.new <T,Y> (Service: T & main.DefaultServiceNeedle<Y>)
	return main.__SadAbstractService_protected.NewChild(Service :: T,class)
end

private.task_map = setmetatable({}::{[SadSystemService]: Controller}, {__mode='k'})
private.task_list = setmetatable({} :: {Controller}, {__mode='v'})
function private:while_active_do ()
	local self = self :: SadSystemService;
	
	local Controller = private.task_map[self]
	local Core : Core = Controller and Controller.Core
	if not Core then
		Core = HxEventCore.new(warn::DefaultF)
		Controller = {Core=Core,Count=0,Me=self}
		private.task_map[self] = Controller
		table.insert(private.task_list, Controller)
	end
	
	return Core:AddEvent()
end

game["Run Service"].Heartbeat:Connect(function(deltaTime: number) 
	for i,v in private.task_list do
		if not v.Me:IsActive() then
			v.Count = 0
			continue
		end
		
		v.Core:DoCall(deltaTime, v.Count > 0)
	end
end)

class.__index = main.__SadAbstractService.class;
class.ClassName = main.Mapping.Class.SadSystemService;
class.Source = script;
class.DoWhileActive = private.while_active_do;

interface.class = class;
interface.new = private.new;

return main:expand({SadSystemService=interface})