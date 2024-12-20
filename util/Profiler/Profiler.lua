do local folder_of_this_file
local module_arg={...}
if module_arg[1] ~= (arg or {})[1] then folder_of_this_file=module_arg[1] .. "."
local is_implicit_init=module_arg[2]:match(module_arg[1] .. "[/\\]init%.lua")
if  not is_implicit_init then folder_of_this_file=folder_of_this_file:match"(.+%.)[^.]+" or "" end else folder_of_this_file=arg[0]:gsub("[^%./\\]+%..+$","")
do local sep=package.path:sub(1,1)
local pwd=sep == "/" and os.getenv"PWD" or io.popen("cd","r"):read"a"
for _ in folder_of_this_file:gmatch"%.%." do pwd=pwd:gsub("[/\\][^/\\]+[/\\]?$","") end
pwd=pwd .. sep
package.path=package.path .. string.format(";%s?.lua;%s?%sinit.lua",pwd,pwd,sep) end
folder_of_this_file=folder_of_this_file:gsub("[/\\]","."):gsub("^%.+","") end
local library_root=folder_of_this_file:sub(1, - 1 -  # "util.Profiler.")
require(library_root .. "_shim") end
local class=require"lib_LuaX._dep.lib.30log"

local find_unused_filename=require"lib_LuaX.util.Profiler.find_unused_filename"
if  not debug or  not debug.getinfo then warn"Profiler requires debug.getinfo(). A No-op profiler will be used instead"
local FakeProfiler=class"FakeProfiler"
function FakeProfiler:init()  end
function FakeProfiler:start()  end
function FakeProfiler:stop()  end
function FakeProfiler:dump() warn"FakeProfiler will not generate an output file" end
return FakeProfiler end

---@class LuaX.Profiler.Function.Call
---@field fn function
---@field instruction_count number
---@class LuaX.Profiler.Function.Line
---@field current_line number
---@field instruction_count number
---@alias LuaX.Profiler.Function.Event { type: "line", line: LuaX.Profiler.Function.Line } | { type: "call", call: LuaX.Profiler.Function.Call }
---@class LuaX.Profiler.Function
---@field short_src string
---@field name string
---@field linedefined number
---@field lastlinedefined number
---@field events LuaX.Profiler.Function.Event[]
---@alias LuaX.Profiler.CallstackItem (debuginfo | { instruction_count: number })
---@class LuaX.Profiler : Log.BaseFunctions

---@field instruction_count number
---@field last_instruction_count number

---@field main_fn LuaX.Profiler.CallstackItem

---@field methods table<function, string>
---@field discovered table<table, true>

---@field callstack LuaX.Profiler.CallstackItem[]
---@field functions table<function, LuaX.Profiler.Function>
---@field ignore table<function, true>

---@field ignore_paths string[]

---@operator call:LuaX.Profiler
---@param opts { sentient: boolean?, ignore: string[]? }?
local Profiler=class"Profiler"
function Profiler:init(opts) opts=opts or {}
self.instruction_count=0
self.last_instruction_count=0
self.methods={}
self.discovered={}
self.callstack={}
self.functions={}
self.ignore={}
if  not opts.sentient then for _,v in pairs(self) do if type(v) == "function" then self.ignore[v]=true end end end
self.ignore_paths={}
if opts.ignore then self:ignore_path(table.unpack(opts.ignore)) end end
---@param ... string paths to ignore
function Profiler:ignore_path(...) for _,path in ipairs(table.pack(...)) do table.insert(self.ignore_paths,path) end end
function Profiler:discover_all_methods() 
self.discovered[package.loaded]=true
self:discover_methods(_G) end
---@param input any
---@param name string?
function Profiler:discover_methods(input,name) if type(input) == "table" then self.discovered[input]=true
local prefix=name and (name .. ".") or ""
for key,value in pairs(input) do if type(key) == "string" and  not self.discovered[value] then 




self:discover_methods(value,prefix .. key) end end elseif type(input) == "function" then if name then self.methods[input]=name end end end

---@param f_info debuginfo
function Profiler:get_function_name(f_info) return self.methods[f_info.func] or f_info.name or f_info.what or f_info.short_src .. ":" .. tostring(f_info.linedefined) end
---@param f_info debuginfo
function Profiler:get_short_src(f_info) if self.methods[f_info.func] and  not self.methods[f_info.func]:match"^package%.loaded%." then return "Lua library function" end
return f_info.short_src end
---@param f_info debuginfo
---@param add { line: LuaX.Profiler.Function.Line?, call: LuaX.Profiler.Function.Call? }
function Profiler:function_add(f_info,add) local addr=f_info.func
if  not self.functions[addr] then ---@type LuaX.Profiler.Function
local entry={["short_src"] = self:get_short_src(f_info),["name"] = self:get_function_name(f_info),["linedefined"] = f_info.linedefined or  - 1,["lastlinedefined"] = f_info.lastlinedefined or  - 1,["events"] = {}}
self.functions[addr]=entry end
local entry=self.functions[addr]
if  not self.main_fn then self.main_fn=f_info end
if add.line then ---@type LuaX.Profiler.Function.Event
local line_entry={["type"] = "line",["line"] = add.line}
table.insert(entry.events,line_entry) end
if add.call then ---@type LuaX.Profiler.Function.Event
local line_entry={["type"] = "call",["call"] = add.call}
table.insert(entry.events,line_entry) end end
---@param f_info debuginfo
function Profiler:function_get(f_info) return self.functions[f_info.func] end
---@param f_info LuaX.Profiler.CallstackItem
function Profiler:callstack_add(f_info) f_info.instruction_count=self.instruction_count
table.insert(self.callstack,f_info) end
function Profiler:callstack_current() return self.callstack[ # self.callstack] end
---@return LuaX.Profiler.CallstackItem
function Profiler:callstack_remove() 
return table.remove(self.callstack, # self.callstack) end
---@param class "count" | "line" | "call" | "return"
function Profiler:trace(class) 
local f_info=debug.getinfo(2,"lSfn")
if self.ignore[f_info.func] then return  end
for _,ignore_path in ipairs(self.ignore_paths) do if f_info.short_src:match(ignore_path) then return  end end
if class == "count" then self.instruction_count=self.instruction_count + 1 elseif class == "line" then self:function_add(f_info,{["line"] = {["current_line"] = f_info.currentline,["instruction_count"] = self.instruction_count - self.last_instruction_count}})
self.last_instruction_count=self.instruction_count elseif class == "call" then 
self:callstack_add(f_info)
self:function_add(f_info,{}) elseif class == "return" and  # self.callstack > 0 then 
local popped_info=self:callstack_remove()
local prev= # self.callstack > 0 and self:callstack_current() or self.main_fn
self:function_add(prev,{["call"] = {["fn"] = popped_info.func,["instruction_count"] = self.instruction_count - popped_info.instruction_count}}) end end
function Profiler:start() local function trace(...) return self:trace(...) end
self:discover_all_methods()
debug.sethook(trace,"crl",1) end
function Profiler:stop() debug.sethook() end
---@param file file*
---@param fmt string
---@param ... any
local function write_format(file,fmt,...) local str=string.format(fmt,...)
return file:write(str) end
---@param file file*
function Profiler:to_kcachegrind(file) file:write"events: Instructions\n"
for _,entry in pairs(self.functions) do write_format(file,"fl=%s\n",entry.short_src)
write_format(file,"fn=%s\n",entry.name)
for _,event in ipairs(entry.events) do local event_type=event.type
if event_type == "line" then local line=event.line
write_format(file,"%d %d\n",line.current_line,line.instruction_count) elseif event_type == "call" then local call=event.call
local call_info=self.functions[call.fn]
write_format(file,"cfl=%s\n",call_info.short_src)
write_format(file,"cfn=%s\n",call_info.name)
write_format(file,"calls=1 %d\n",call_info.linedefined)
write_format(file,"%d %d\n",call_info.lastlinedefined,call.instruction_count) end end
write_format(file,"\n")
file:flush() end end
---@param filename string
---@param format "KCacheGrind"
function Profiler:dump(filename,format) 
self:stop()
local filename=find_unused_filename(filename)
local format_handler=({["KCacheGrind"] = self.to_kcachegrind})[format]
if  not format_handler then error(string.format("Unknown profiler format \"%s\"",format)) end
local file=io.open(filename,"w")
if  not file then error(string.format("Unable to open %s",filename)) end
format_handler(self,file) end
return Profiler