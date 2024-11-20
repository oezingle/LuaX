describe("generated functions", function()
    local function generator()
        return function()
            return "Hello World!"
        end
    end

    local a = generator()
    local b = generator()

    it("are not equal", function()
        assert.Not.equal(a, b)
    end)

    it("are equal strings (unstripped)", function()
        local a_s = string.dump(a, false)
        local b_s = string.dump(b, false)

        assert.equal(a_s, b_s)
    end)


    it("are equal strings (stripped)", function()
        local a_s = string.dump(a, true)
        local b_s = string.dump(b, true)

        assert.equal(a_s, b_s)
    end)
end)

describe("loaded functions", function()
    local chunk = [[
        return function ()
            return "Hello World!"
        end
    ]]

    it("are equal", function()
        local getchunk, err = load(chunk)

        if not getchunk then
            error(err)
        end

        local a = getchunk()
        local b = getchunk()
        local a_s = string.dump(a, true)
        local b_s = string.dump(b, true)

        assert.equal(a_s, b_s)
    end)

    it("are equal even if loaded seperately", function()
        local getchunk, err = load(chunk)
        
        if not getchunk then
            error(err)
        end

        local getchunk2, err = load(chunk)

        if not getchunk2 then
            error(err)
        end

        local a = getchunk()
        local b = getchunk2()
        local a_s = string.dump(a, true)
        local b_s = string.dump(b, true)

        assert.equal(a_s, b_s)
    end)
end)
