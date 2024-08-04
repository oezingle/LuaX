#!/usr/bin/lua

local argparse      = require("lib.argparse")
local basename = require("src.util.polyfill.path.basename")
local to_luapath = require ("src.cmd.to_luapath")
local transpile = require("src.cmd.transpile")

local function cmd()
    local parser = argparse("LuaX")

    parser
        :option("-r --recursive", "Recursively check, either to any depth (implicit/\"auto\") or a specified number")
        :args("?")

    parser
        :option("--remap", "Match imports for $1, replacing with $2")
        :args(2)
        :count("*")

    parser
        :flag("-a --auto-remap", "Attempt to automatically remap imports given input & output")

    parser
        :argument("input", "Input file/folder path")

    parser
        :argument("output", "Output file/folder path")

    local args = parser:parse()

    if args.recursive then
        if #args.recursive == 0 or args.recursive[1] == "auto" then
            args.recursive = true
        else
            local depth = tonumber(args.recursive[1])

            if not depth then
                print(string.format("--recursive: expected number, got %q", args.recursive[1]))

                os.exit(1)
            end

            args.recursive = depth
        end
    else
        args.recursive = false
    end

    local remap = {}
    for _, pair in ipairs(args.remap) do
        table.insert(remap, {
            from = pair[1],
            to = pair[2]
        })
    end

    if args.auto_remap then
        table.insert(remap, {
            from = to_luapath(basename(args.input)),
            to = to_luapath(basename(args.output))
        })
    end

    local transpile_options = {
        inpath = args.input,
        outpath = args.output,
        recursive = args.recursive,
        remap = remap
    }

    transpile(transpile_options)
end

return cmd
