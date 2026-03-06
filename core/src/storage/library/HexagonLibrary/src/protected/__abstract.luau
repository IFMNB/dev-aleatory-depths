local private = {}
local abstract = {}

-- You should define this property as a procedure or default function. Without this, you will get an error.
function private.class_abstract_field (...: any)
	error('Descendant didnt override this abstract property')
end
-- You should define this property as a methode. Without this, you will get an error.
function private:class_self_abstract (...: any)
	error('Descendant didnt override this abstract property for himself')
end
-- This function cannot be called specifically in this context. However, it is available for calling in another case.
function private.class_not_implemented (...: any)
	error('This function cannot called in this context')
end
-- This function cannot be called specifically in this context. However, it is available for calling in another case.
function private:class_not_implemented_for_self (...: any)
	return private.class_not_implemented(...)
end

-- You should never call this function, because class does not involve its use
function private.class_overrided_error (...)
	error('This function was overrided and cant be called')
end
-- You should never call this methode, because object does not involve its use
function private:class_self_overrided_error (...)
	return private.class_overrided_error(...)
end

--[[Wraps a function and returns a new function wrapping the original function.]]
function private.Wrap <T,F, R, U...> (Callback: (...any)->()?, Call: F&((T, ...R)->U...), CallAfter: (...any)->()?)
	return (function (...: R)
		if Callback then
			Callback(...)
		end
		local r0 = {Call(...)}
		if CallAfter then
			CallAfter(...)
		end
		return unpack(r0)
	end) :: F
end


abstract.ShouldOverrided = private.class_abstract_field
abstract.SelfOverride = private.class_self_abstract
abstract.ToNeverUse = private.class_overrided_error
abstract.SelfNeverUse = private.class_self_overrided_error
abstract.NotImplemented = private.class_not_implemented
abstract.SelfNotImplemented = private.class_not_implemented_for_self
abstract.Wrap = private.Wrap

return abstract