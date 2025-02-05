#!/usr/bin/env lua

local ensure_warn = require("src.util.ensure_warn")
local table_pack  = require("src.util.polyfill.table.pack")

ensure_warn()

-- TODO init 'test' is out-of-date

-- check if ... (provided by import) matches arg (provided by lua command line)
if table_pack(...)[1] ~= (arg or {})[1] then
    -- this file has been imported
    return require("src.entry.export")
else
    local cmd = require("src.cmd.cmd")

    cmd()
end
