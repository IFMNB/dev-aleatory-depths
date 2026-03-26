local debugframe = script.Parent.Debug.Frame
for i,v in script:GetDescendants() :: {Instance} do
	if v:IsA('ModuleScript') then
		local r = require(v)(debugframe) :: any
	end
end