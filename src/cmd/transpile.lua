local join        = require("src.util.polyfill.path.join")
local ls          = require("src.cmd.fs.list").ls
local mkdir       = require("src.cmd.fs.mkdir").mkdir
local is_dir      = require("src.cmd.fs.is_dir")
local cp          = require("src.cmd.fs.cp")
local is_lua_file = require("src.cmd.fs.is_lua_file")
local parse_file  = require("src.cmd.parse_file")
local dirname    = require("src.util.polyfill.path.dirname")

---@class LuaX.Cmd.TranspileOptions
---@field inpath string
---@field outpath string
---@field recursive boolean|number
---@field remap { from: string, to: string }[]

---@param options LuaX.Cmd.TranspileOptions
local function transpile(options)
    local inpath = options.inpath
    local outpath = options.outpath

    local should_recurse =
        (type(options.recursive) == "boolean" and options.recursive) or
        (type(options.recursive) == "number" and options.recursive >= 1)

    if is_lua_file(inpath) then
        local parsed = parse_file(inpath)

        for _, remap in ipairs(options.remap) do
            parsed = parsed:gsub("require%(%s*([\"'])" .. remap.from, "require(%1" .. remap.to)
        end

        if outpath:match("luax$") then
            outpath = outpath:gsub("luax$", "lua")
        end

        local outfile = io.open(outpath, "w")

        if not outfile then
            error(string.format(
                "Unable to transpile %q: cannot open %q",
                inpath, outpath
            ))
        end

        outfile:write(parsed)

        outfile:flush()
        outfile:close()
    elseif is_dir(inpath) and should_recurse then
        local outdir = dirname(outpath)

        mkdir(outdir)

        for _, file in ipairs(ls(inpath)) do
            local new_inpath = join(inpath, file)
            local new_outpath = join(outpath, file)

            local new_options = {
                inpath = new_inpath,
                outpath = new_outpath,
                recursive = type(options.recursive) == "number" and options.recursive - 1 or options.recursive,
                remap = options.remap,
            }

            transpile(new_options)
        end
    else
        cp(inpath, outpath)
    end
end

return transpile
