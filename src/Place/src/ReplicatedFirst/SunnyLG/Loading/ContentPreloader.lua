local ContentProvider = game:GetService('ContentProvider')

local ContentPreloader = {};
ContentPreloader.__index=ContentPreloader;
ContentPreloader.Loaded = false;
ContentPreloader.Count = 0;
ContentPreloader.CurrentLoad = nil :: string?;

ContentPreloader.Assets = {} :: {any};
ContentPreloader.Callbacks = {} :: { () -> ()};
ContentPreloader.AssetCallbacks = {} :: {(asset: Instance) -> ()};

type ContentPreloader = typeof(ContentPreloader.new())

function ContentPreloader.new()
	local self = setmetatable({}, ContentPreloader);
	self.Assets = table.clone(ContentPreloader.Assets);
	self.Callbacks = table.clone(ContentPreloader.Callbacks);
	self.AssetCallbacks = table.clone(ContentPreloader.AssetCallbacks);
	return self
end

function ContentPreloader:ToLoad (Descendants: {any}|any)
	local self = self :: ContentPreloader
	table.insert(self.Assets, type(Descendants) == 'table' and Descendants or {Descendants})
	local a0 : number = 0
	for i,v in self.Assets do a0 += if type(v) == 'table' then #v else i end
	ContentPreloader.Count = a0;
	return self
end

function ContentPreloader:OnLoaded (Callback: () -> ())
	local self = self :: ContentPreloader
	table.insert(self.Callbacks, Callback)
	return self
end

function ContentPreloader:ClearContent ()
	local self = self :: ContentPreloader
	table.clear(self.Assets);
	return self
end

function ContentPreloader:OnAssetLoad (Callback: (asset: Instance) -> ())
	local self = self :: ContentPreloader

	table.insert(self.AssetCallbacks, Callback)
	return self
end

function ContentPreloader:PreloadAsync ()
	local self = self :: ContentPreloader
	local thread = coroutine.running()

	assert(type(self.Assets) == 'table', 'No Assets to load')
	assert(#self.Assets > 0, 'No Assets to load')

	local cor = coroutine.create(function ()
		for i,v in self.Assets do
			for i,v in v do
				self.CurrentLoad = tostring(v and v.Name or v or nil);

				local cor = coroutine.create(function ()
					if self.AssetCallbacks then
						for i,ac in self.AssetCallbacks do
							xpcall(ac,warn,v)
						end
					end
					ContentProvider:PreloadAsync({v})
				end)

				coroutine.resume(cor)
				task.wait()
			end
		end

		task.wait()
		coroutine.resume(thread)
	end)


	coroutine.resume(cor)
	coroutine.yield()

	if self.Callbacks then
		for i,v in self.Callbacks do
			xpcall(v,warn)
		end
		table.clear(self.Callbacks);
	end

	self.Loaded = true;
end

return ContentPreloader