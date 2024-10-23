local function inherit_contexts(caller) if  not caller then return {} end
local inherit=caller.props.__luax_internal.context
return setmetatable({},{["__index"] = inherit}) end
return inherit_contexts