local clock = os.clock

describe("table equality", function()
    it("is slower than strings", function()
        local t_start = clock()

        do
            local table_a = {}
            local table_b = table_a

            for _ = 1, 100 do
                local equal = table_a == table_b
            end

            table_b = {}

            for _ = 1, 100 do
                local equal = table_a == table_b
            end
        end

        local t_mid = clock()

        do
            local string_a = "hello world"
            local string_b = string_a 
    
            for _=1,100 do
                local equal = string_a == string_b
            end
    
            string_b = "hello"
    
            for _=1,100 do
                local equal = string_a == string_b
            end
        end

        local t_end = clock()

        local t_table = t_mid - t_start
        local t_string = t_end - t_mid

        assert.True(t_table > t_string)
    end)
end)
