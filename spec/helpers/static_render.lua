
local XMLElement = require("src.util.NativeElement.XMLElement")

local Renderer = require("src.util.Renderer")
local ProfiledRenderer = require("src.util.Renderer.Profiled")

-- Mock LuaX. not ideal but busted does a good job of cleaning globals
LuaX = {}

---@param element LuaX.ElementNode
---@param options { profiled?: boolean }?
local function static_render (element, options)
    options = options or {}

    local renderer = options.profiled and ProfiledRenderer() or Renderer()

    local root = XMLElement.get_root({
        type = "root",
        children = {}
    })

    renderer:render(element, root)

    return root.children[1]
end

return static_render