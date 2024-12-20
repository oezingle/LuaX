
local use_context = require("src.hooks.use_context")
local Portal      = require("src.Portal")

---@alias LuaX.Hooks.UsePortal fun (name?: string): LuaX.Portal

local function use_portal (name)
    local portals = use_context(Portal.Context)

    local portal = portals[name or "LuaX.Portal"]

    return assert(portal, name and string.format("No portal by name %q", name) or "No default portal")
end

return use_portal