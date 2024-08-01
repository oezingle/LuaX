
local ClientContext = require("awesome.ClientContext")
local use_context   = require("src.hooks.use_context")

local function use_client ()
    return use_context(ClientContext)
end

return use_client