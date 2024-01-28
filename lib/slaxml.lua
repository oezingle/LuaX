
local function slaxml_shiv ()
    -- hack im not proud of
    package.loaded["slaxml"] = require("lib.slaxml.slaxml")
    
    return require("lib.slaxml.slaxdom")
end

return slaxml_shiv()
