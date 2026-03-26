--!strict

-- box of tools to make your life easier

local plugin = script 

local public = {}


public.Primetive = {}
public.Tables = {}
public.Special = {}
public.Buffer = {}

-- Used in big table manipulations.
function public.Tables.Table ()
	return require(plugin.tbl)
end
-- Plugin destributes advanced buffer tools.
function public.Buffer.Buffer ()
	return require(plugin.buf)
end
-- Used to work with special numbers.
function public.Primetive.Number ()
	return require(plugin.num)
end
-- Related to all ASCII strings.
function public.Primetive.String ()
	return require(plugin.str)
end
-- Pseudo-C syntax.
function public.Special.Int ()
	return require(plugin.num.int)
end
-- Extra buffer tools, used to work with strings.
function public.Buffer.BufferString ()
	return require(plugin.buf.bufStr)
end
-- Provides extra functionality.
function public.Special.Import ()
	return require(plugin.import)
end
-- Retunrs extra tools to work with metatables.
function public.Tables.Metatables ()
	return require(plugin.metatable)
end
-- Another __index way to prototype something like in POP (OOP)
function public.Tables.Expansion ()
	return require(plugin.oop)
end
-- Shortcuts to work with Vector3 value types
function public.Primetive.Vector3 ()
	return require(plugin.vector3)
end
-- Shortcuts to work with CFrame value types
function public.Primetive.CFrame ()
	return require(plugin.Cframe)
end

-- Special plugin to protect data from _GC
function public.Tables.Links ()
	return require(plugin.linker)
end
-- Can private linked private data.
function public.Tables.Shadow ()
	return require(plugin.linker.shadow)
end
-- Special debug plugin. Unavailable in production.
function public.Special.Debug ()
	return require(plugin.debug)
end
-- Special plugin to work with coroutines.
function public.Special.Coroutine ()
	return require(plugin.coroutine)
end
-- Special plugin to work with roblox instances.
function public.Special.Instances ()
	return require(plugin.coroutine.instance)
end

-- Special construction on LinkerPlugin, used to save data by roblox instance.
function public.Tables.Reference ()
	return require(plugin.linker.reference)
end

return public