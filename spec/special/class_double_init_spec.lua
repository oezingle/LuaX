
local class = require("lib.30log")

local SomeClass = class("SomeClass")

local instance_count = 0

function SomeClass:init()
    instance_count = instance_count + 1
end

local instance = SomeClass()

local instance_two = instance.class()

assert.equal(2, instance_count)