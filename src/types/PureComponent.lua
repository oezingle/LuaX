---@meta

---@class PureComponent<Props> : Log.BaseFunctions, { get_prop: fun(self: PureComponent<Props>, prop: Props): any, set_prop: fun(self: PureComponent<Props>, prop: Props, value: any) } A component that can be rendered and modified
---@field set_children fun(self: PureComponent, children: Component.Return)
---@field get_children fun(self: PureComponent): Component.Return
---@field get_prop fun(self: PureComponent, prop: string | number): any
---@field set_prop fun(self: PureComponent, prop: string | number, value: any)