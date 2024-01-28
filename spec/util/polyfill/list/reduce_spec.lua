
local list_reduce = require("src.util.polyfill.list.reduce")

describe("list_reduce", function ()
    it("can be used to select deep values from table", function ()
        local fields = { "widget", "textbox" }
        
        local wibox = {
            widget = {
                textbox = "woohoo"
            }
        }

        local reduced = list_reduce(fields, function(object, key)
            return object[key]
        end, wibox)

        assert.equal("woohoo", reduced)
    end)
end)