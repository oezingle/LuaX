-- TODO this code is in big need of deprecation. 
-- TODO cmd should match files (recursively if **), replacing %path% w/ full path, %match% with the generic wildcard result, etc etc.

--- Get a function to dump to output
---@param infile string
---@param outfile string
---@return fun (code: string): nil dump
local function get_outfile(infile, outfile)
    -- TODO more succinct pattern?
    if outfile == "/dev/stdout" then
        return function(code)
            io.stdout:write(code)
        end
    end

    -- match everything but extension. Some files may not have an extension, so
    -- then return the whole filename
    local filename = infile:match("()%..-$") or infile

    -- replace shit, hopefully we get a usable path
    -- TODO consider * (wildcard) -> filename?
    local path = outfile
        :gsub("%path%", infile)
        :gsub("%filename%", filename)

    local file = io.open(path, "w")

    if not file then
        error(string.format(
            "Unable to transpile %s: output file %s does not exist.",
            infile, outfile
        ))
    end

    return function(code)
        file:write(code)

        file:flush()
        file:close()
    end
end

return get_outfile
