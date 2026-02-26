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


-- You should never call this function, because class does not involve its use
function private.class_overrided_error (...)
	error('This function was overrided and cant be called')
end
-- You should never call this methode, because object does not involve its use
function private:class_self_overrided_error (...)
	return private.class_overrided_error(...)
end




abstract.ShouldOverrided = private.class_abstract_field
abstract.SelfOverride = private.class_self_abstract
abstract.ToNeverUse = private.class_overrided_error
abstract.SelfNeverUse = private.class_self_overrided_error

return abstract