
local class = require("lib.30log")

local SomeClass = class("SomeClass")

function SomeClass:init()
    print("Instance!")
end

local instance = SomeClass()

-- print(SomeClass.class)
-- print(instance.class)

local instance_two = instance.class()