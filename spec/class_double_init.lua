
local class = require("lib.30log")

local SomeClass = class("SomeClass")

function SomeClass:init()
    print("Instance!")
end

local instance = SomeClass()

local instance_two = instance.class()