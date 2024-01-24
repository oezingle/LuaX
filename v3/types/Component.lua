
---@meta 

--- TODO FIXME class that extends Log.BaseFunctions as a type?

---@alias LuaX.Generic.FunctionComponent<Props> fun(props: Props): (LuaX.ElementNode | nil)
---@alias LuaX.FunctionComponent LuaX.Generic.FunctionComponent<LuaX.Props>

---@alias LuaX.Generic.Component<Props> string | LuaX.Generic.FunctionComponent<Props>
---@alias LuaX.Component LuaX.Generic.Component<LuaX.Props>