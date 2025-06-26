
-- Fengari has awful 

local wasm = require("js").wasm

if wasm then
    return error
else
    local vanilla_error = error
    local error = function(msg, level)
        msg = debug.traceback(msg)
    
        vanilla_error(msg, level)
    end
    
    return error
end
