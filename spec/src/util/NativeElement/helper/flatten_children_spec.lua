local flatten_children   = require("src.util.NativeElement.helper.flatten_children")
local NativeElement      = require('src.util.NativeElement')

local LightNativeElement = NativeElement:extend('LightNativeElement')
function LightNativeElement:init()
    -- nada
end

-- create_native_element is too long to type, so create_native_element -> cna
local function cna()
    return LightNativeElement()
end

describe("flatten_children", function()
    --[[
    it("flattens a single instance", function ()
        local children = cna()

        local flat = flatten_children(children, {})

        assert.equal(1, #flat)

        assert.equal(nil, next(flat[1].key))
    end)

    it("flattens multiple equal children", function ()
        local children = {
            cna(),
            cna(),
            cna()
        }

        local flat = flatten_children(children, {})

        assert.equal(3, #flat)

        for i, entry in ipairs(flat) do
            assert.equal(1, #entry.key)

            assert.equal(i, entry.key[1])
        end
    end)
    ]]

    it("flattens deeply nested children", function ()
        local children = {
            cna(),
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
                nil,
                cna()
            }
        }

        local flat = flatten_children(children, {})

        assert.equal(7, #flat)

        local function assert_key (expected, given)
            assert.equal(#expected, #given)

            for i, val in ipairs(expected) do
                assert.equal(val, given[i])
            end
        end

        assert_key({1}, flat[1].key)

        assert_key({2, 1}, flat[2].key)
        assert_key({2, 2}, flat[3].key)

        assert_key({2, 3, 1}, flat[4].key)
        assert_key({2, 3, 2}, flat[5].key)
        assert_key({2, 3, 3}, flat[6].key)

        assert_key({3, 2}, flat[7].key)
    end)

    --[[
    it("passes existing keys", function ()
        local children = {
            nil,
            nil,
            nil, 
            cna()
        }

        local flat = flatten_children(children, { 1, 2, 3})

        assert.equal(1, #flat)

        local key = flat[1].key
        assert.equal(1, key[1])
        assert.equal(2, key[2])
        assert.equal(3, key[3])
        assert.equal(4, key[4])
    end)
    ]]
end)
