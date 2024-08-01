local join = require("src.util.polyfill.path.join")
local ls = require("src.cmd.list").ls
local escape = require("src.util.polyfill.string.escape")
local parse_file = require("src.cmd.parse_file")
local is_dir     = require("src.cmd.is_dir")

--- TODO move elsewhere for test coverage
local function is_lua_file(path)
    local extensions = {
        ".lua",
        ".luax"
    }

    for _, extension in ipairs(extensions) do
        if path:match(escape(extension) .. "$") then
            return true
        end
    end

    -- TODO parse contents of file, checking for #!/<somepath>/lua ?

    return false
end

---@param realpath string
---@return string
local function to_luapath (realpath)
    local path = realpath:gsub("[/\\]", ".")

    if path:sub(1,1) == "." then
        path = path:sub(2)
    end

    if path:sub(-1,-1) == "." then
        path = path:sub(1, -2)
    end

    return path
end

---@param indir string
---@param outdir string
local function transpile_dir(indir, outdir)
    -- TODO paltform agnostic version of this
    os.execute(string.format("mkdir -p %q", outdir))

    for _, file in ipairs(ls(indir)) do
        local inpath = join(indir, file)
        local outpath = join(outdir, file)

        if is_lua_file(inpath) then
            local parsed = parse_file(inpath)

            -- TODO remap imports better
            -- parsed = parsed:gsub("require%(%s*" .. to_luapath(indir), "require(" .. to_luapath(outdir))
            parsed = parsed:gsub("require%(%s*([\"'])" .. to_luapath(indir), "require(%1" .. to_luapath(outdir))

            if outpath:match("luax$") then
                outpath = outpath:gsub("luax$", "lua")
            end

            local outfile = io.open(outpath, "w")

            if not outfile then
                error(string.format(
                    "Unable to transpile %s: output file %s does not exist.",
                    inpath, outpath
                ))
            end

            outfile:write(parsed)

            outfile:flush()
            outfile:close()
        elseif is_dir(inpath) then
            transpile_dir(inpath, outpath)
        else
            -- TODO os agnostic
            os.execute(string.format("cp %q %q", inpath, outpath))
        end
    end
end

return transpile_dir
