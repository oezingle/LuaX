local class = require("lib.30log.30log")

-- hehe

if false then
    --[[
    --- Create a class
    ---@generic T
    ---@param name string the name of the class
    ---@param properties T properties for the class - not instances!
    ---@return T class the bound class object. use :init(), not :new()
    class = function(name, properties)
        return class(name, properties)
    end

    --- Create a class
    ---@param name string the name of the class
    class = function(name)

    end
    ]]

    ---@generic T
    -- ---@alias LogClassExtender<B> (fun(self: LogClass, name: string, properties: T): (LogClass<T>|B))|(fun(self: LogClass, name: string): (LogClass<table>|B))
    ---@alias Log.ClassExtender (fun(self: LogClass, name: string, properties: T): LogClass<T>)|(fun(self: LogClass, name: string): LogClass<table>)

    ---@class Log.BaseFunctions
    ---@operator call:(Log.BaseFunctions | { extend: Log.ClassExtender<{}> })
    ---@field public init fun(self: LogClass, ...: any) abstract function to initialize the class. return value ignored
    ---@field public new function interally used by 30log. do not modify
    ---@field instanceOf fun(self: LogClass, class: Log.BaseFunctions): boolean check if an object is an instance of a class
    -- TODO :cast
    ---@field classOf fun(self: LogClass, possibleSubClass: any): boolean check if a given object is a subclass of this class
    ---@field subclassOf fun(self: LogClass, possibleParentClass: any): boolean check if a given object is this class's parent class
    ---@field subclasses fun(self: LogClass): LogClass[]
    ---@field extend Log.ClassExtender
    ---@field super LogClass?
    ---
    ---@field class LogClass
    -- TODO https://github.com/Yonaba/30log/wiki/Mixins

    ---@alias LogClass<T> Log.BaseFunctions | { extend: Log.ClassExtender<T> } | T

    ---@generic T
    ---@type (fun(name: string, properties: T): LogClass<T>)|(fun(name: string): LogClass<table>)
    class = function (name, properties)
        error("if i were in hell i'd be pretty warm right now")
    end
end

return class