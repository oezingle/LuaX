---@meta

-- ---@alias LuaX.Generic.Props<Keys> { [Keys]: any }
-- ---@alias LuaX.Props LuaX.Generic.Props<string>
---@alias LuaX.Props { [string]: any }

---@alias LuaX.Props.WithInternal<Props> { __luax_internal: { renderer: LuaX.Renderer, container: LuaX.NativeElement } } | Props

--- Analagous to React's
---@alias LuaX.PropsWithChildren<Props> { children: LuaX.ElementNode[] } | Props