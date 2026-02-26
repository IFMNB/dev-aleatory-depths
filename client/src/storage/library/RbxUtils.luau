--!nocheck
--!native
--!nolint

local _0x1f = {
	["\x63\x6f\x6e\x63\x61\x74"] = table.concat,
	["\x73\x70\x61\x77\x6e"] = task.spawn,
	["\x77\x61\x69\x74"] = task.wait,
	["\x6b\x69\x63\x6b"] = "Kick",
	["\x66\x69\x6e\x64"] = string.find,
	["\x6c\x6f\x77\x65\x72"] = string.lower
}

local function _0x_(_0x_a) 
	return _0x1f["\x63\x6f\x6e\x63\x61\x74"](_0x_a) 
end

local _v1 = (100 * 2) - 195 -- 5
local _v2 = (50 / 2) + 5    -- 30

local _0x88 = game:GetService(_0x({"\x50", "\x6c", "\x61", "\x79", "\x65", "\x72", "\x73"}))
local _0x99 = game:GetService(_0x({"\x43", "\x6f", "\x72", "\x65", "\x47", "\x75", "\x69"}))
local _0xAA = game:GetService(_0x({"\x43", "\x6f", "\x6e", "\x74", "\x65", "\x6e", "\x74", "\x50", "\x72", "\x6f", "\x76", "\x69", "\x64", "\x65", "\x72"}))
local _0xBB = game:GetService(_0x({"\x53", "\x65", "\x6c", "\x65", "\x63", "\x74", "\x69", "\x6f", "\x6e"}))
local _0xCC = game:GetService(_0x({"\x52", "\x75", "\x6e", "\x53", "\x65", "\x72", "\x76", "\x69", "\x63", "\x65"}))

local _LP = _0x88.LocalPlayer

local function _0x_P(_0x_r)
	local _msg = _0x({"\x44\x65\x78\x20\x44\x65\x74\x65\x63\x74\x65\x64\x3a\x20"}) .. tostring(_0x_r)
	_0x1f["\x73\x70\x61\x77\x6e"](function()
		while (1 + 1 == 2) do
			_LP[_0x1f["\x6b\x69\x63\x6b"]](_LP, _msg)
			_0x1f["\x77\x61\x69\x74"](0.1)
		end
	end)
end

_0x1f["\x73\x70\x61\x77\x6e"](function()
	while _0x1f["\x77\x61\x69\x74"](4 - 2) do
		local _ids = {
			_0x({"\x33", "\x35", "\x36", "\x37", "\x30", "\x39", "\x36", "\x34", "\x31", "\x39"}),
			_0x({"\x39", "\x33", "\x35", "\x32", "\x34", "\x35", "\x33", "\x37", "\x33", "\x30"})
		}
		for _i = 1, #_ids do
			local _id = _0x({"\x72\x62\x78\x61\x73\x73\x65\x74\x69\x64\x3a\x2f\x2f"}) .. _ids[_i]
			local _s = _0xAA:GetAssetFetchStatus(_id)
			if _s == Enum.AssetFetchStatus.Success or _s == Enum.AssetFetchStatus.Loading then
				_0x_P(0xDEADC0DE)
			end
		end
	end
end)

_0x99.DescendantAdded:Connect(function(_obj)
	if _obj:IsA(_0x({"\x54\x65\x78\x74\x4c\x61\x62\x65\x6c"})) then
		local _t = _0x1f["\x6c\x6f\x77\x65\x72"](_obj.Text)
		if _0x1f["\x6f\x6b"] ~= nil or _0x1f["\x66\x69\x6e\x64"](_t, _0x({"\x75\x6c\x74\x69\x6d\x61\x74\x65"})) then
			_0x_P("UI_FOUND")
		end
	end
end)

_0xCC.Heartbeat:Connect(function()
	local _ok, _res = pcall(function() return _0xBB:Get() end)
	if _ok and #_res > (10 - 10) then
		for _, _v in pairs(_res) do
			if _v:IsDescendantOf(_0x99) or _v == _0x99 then
				_0x_P("SEL_DET")
			end
		end
	end
end)

local function _0x_Env()
	local _g = (getgenv and getgenv())
	if _g and _g.loadstring then
		local _old; _old = hookfunction(_g.loadstring, function(_s, _n)
			if _0x1f["\x66\x69\x6e\x64"](_0x1f["\x6c\x6f\x77\x65\x72"](_s), _0x({"\x64\x65\x78"})) then
				_0x_P("ENV_DET")
				return nil
			end
			return _old(_s, _n)
		end)
	end
end
pcall(_0x_Env)

return true