local argparse   = require("lib.argparse")
local transpile_dir = require("src.cmd.transpile_dir")

local parse_file = require("src.cmd.parse_file")


-- I genuinely hate the args available as of right now.
local function cmd()
    -- TODO FIXME https://github.com/mpeterv/argparse
    local parser = argparse("LuaX")

    --[[
    parser
        :option("--convert", "Transpile an input file to an output file.")
        :args(2)
        :count("*")

    parser
        :option("--file", "Transpile an input file to stdout.")
        :args(1)
        :count("*")
    ]]

    parser
        :option("--dir", "Transpile a directory to an output")
        :args(2)
        :count("*")

    local args = parser:parse()

    for _, dirs in ipairs(args.dir) do
        local indir = dirs[1]
        local outdir = dirs[2]

        transpile_dir(indir, outdir)
    end

    --[[
    for _, convert in ipairs(args.convert) do
        local convert_in = convert[1]
        local convert_out = convert[2]

        local parsed = parse_file(convert_in)

        local outfile = io.open(convert_out, "w")

        if not outfile then
            error(string.format(
                "Unable to transpile %s: output file %s does not exist.",
                convert_in, convert_out
            ))
        end

        outfile:write(parsed)

        outfile:flush()
        outfile:close()
    end

    for _, filename in ipairs(args.file) do
        local parsed = parse_file(filename)

        print(parsed)
    end
    ]]
end

return cmd
