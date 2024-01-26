
local set_child_by_key = require("v3.util.NativeElement.helper.set_child_by_key")

local not_a_native_element = "NOT A NATIVE ELEMENT" 


describe("set_child_by_key", function ()
    it("sets a sub-sub-sub-child", function ()
        local t ={}
        
        set_child_by_key(t, { 1, 2, 1}, not_a_native_element --[[@as LuaX.NativeElement]])

        assert.equal(t[1][2][1], not_a_native_element)
    end)

    -- TODO chore: more tests (sorry!)
end)