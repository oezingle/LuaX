local find_unused_filename = require("src.util.Profiler.find_unused_filename")

describe("find_unused_filename", function()
    it("returns the path as-is if it doesn't exist", function()
        stub(io, "open", function(path)
            return nil
        end)

        local path = find_unused_filename("path")

        assert.equal("path", path)

        ---@diagnostic disable-next-line:undefined-field
        io.open:revert()
    end)

    it("returns path-1 if path exists", function()
        stub(io, "open", function(path)
            if path == "path" then
                return true
            end

            return nil
        end)

        local path = find_unused_filename("path")

        assert.equal("path-1", path)

        ---@diagnostic disable-next-line:undefined-field
        io.open:revert()
    end)

    it("returns path-2 if path exists", function()
        stub(io, "open", function(path)
            if path == "path" or path == "path-1" then
                return true
            end

            return nil
        end)

        local path = find_unused_filename("path")

        assert.equal("path-2", path)

        ---@diagnostic disable-next-line:undefined-field
        io.open:revert()
    end)

    it("panics after 1024 attempts to find a filename", function()
        stub(io, "open", function(path)
            return true
        end)

        assert.error(function ()
            find_unused_filename("path")
        end)

        ---@diagnostic disable-next-line:undefined-field
        io.open:revert()
    end)
end)
