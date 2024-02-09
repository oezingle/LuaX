
local argparse = require("lib.argparse.src.argparse")

if false then
    ---@class ArgParse.Option
    ---@field args fun(self: ArgParse.Option, args: number): ArgParse.Option set the number of arguments per option. ie parser:option("double"):args(2) -> <program> --double arg1 arg2
    ---@field target fun(self: ArgParse.Option, target: string): ArgParse.Option
    ---@field count fun(self: ArgParse.Option, count: "*"|string|number): ArgParse.Option set the count of this option possible
    ---@field choices fun(self: ArgParse.Option, choies: string[]): ArgParse.Option set the possible choices for that option

    ---@class ArgParse.Flag
    ---@field target fun(self: ArgParse.Flag, target: string): ArgParse.Flag
    ---@field count fun(self: ArgParse.Flag, count: "*"|string|number): ArgParse.Flag set the count of this option possible

    ---@class ArgParse.Argument
    ---@field count fun(self: ArgParse.Flag, count: "*"|string|number): ArgParse.Flag set the count of this option possible
    ---@field choices fun(self: ArgParse.Argument, choies: string[]): ArgParse.Argument set the possible choices for that option

    ---@class ArgParse
    ---@field argument fun(self: ArgParse, name: string, description: string?, default: string?): ArgParse.Argument
    ---@field option fun(self: ArgParse, flags: string, description: string?, default: string?): ArgParse.Option
    ---@field flag fun(self: ArgParse, flags: string, description: string?): ArgParse.Flag
    ---@field parse fun(self: ArgParse)
    ---@operator call(string):ArgParse
    argparse = {}
end

return argparse