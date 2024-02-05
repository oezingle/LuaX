
local count_children_by_key = require('src.util.NativeElement.helper.count_children_by_key')
local NativeElement         = require('src.util.NativeElement.init')

local LightNativeElement = NativeElement:extend('LightNativeElement')
function LightNativeElement:init()
    -- nada
end

-- create_native_element is too long to type, so create_native_element -> cna
local function cna ()
    return LightNativeElement()
end

describe("count_children_by_key", function ()
    it("counts simple lists with empty keys", function ()
        local count = count_children_by_key({
            cna(),
            cna(),
            cna()
        }, {})

        assert.equal(3, count)
    end)
    
    it("counts simple lists with full keys", function ()
        local count = count_children_by_key({
            cna(),
            cna(),
            cna(),
        }, {  2})

        assert.equal(count, 2)
    end)
    
    it("counts partially nested lists with empty keys", function ()
        local count = count_children_by_key({
            cna(),
            {
                cna(),
                cna(),
                cna(),
            },
            cna(),
        }, { })

        assert.equal(count, 5)
    end)

    it("counts partially nested lists with full keys", function ()
        local count = count_children_by_key({
            cna(),
            {
                cna(),
                cna(),
                cna(),
            },
            cna(),
        }, { 2, 3 })

        assert.equal(count, 4)
    end)

    it("counts complex lists with full keys", function ()
        local children = {
            {
                cna(),
                cna(),
                {
                    cna(),
                    cna(),
                    cna()
                }
            },
            {
                cna(),
                cna(),
                { 
                    cna(),
                }
            },
            cna(),
        }
        
        local count1 = count_children_by_key(children, { 2, 3 })

        assert.equal(count1, 8)

        local count2 = count_children_by_key(children, { 2, 3, 1 })

        assert.equal(count2, 8)
    end)
end)