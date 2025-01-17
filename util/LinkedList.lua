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
local library_root=folder_of_this_file:sub(1, - 1 -  # "util.")
require(library_root .. "_shim") end
---@class LinkedList.Node<T> : Log.BaseFunctions
---@operator call:LinkedList.Node
---@field value any
---@field next LinkedList.Node|nil
---@field prev LinkedList.Node|nil
local class=require"lib_LuaX._dep.lib.30log"
---@param value any the value of the node
local LinkedListNode=class"LinkedListNode"
function LinkedListNode:init(value) self.value=value end
---@param node LinkedList.Node|nil
---@return self self for convienience
function LinkedListNode:set_next(node) self.next=node
return self end
---@param node LinkedList.Node|nil
---@return self self for convienience
function LinkedListNode:set_prev(node) self.prev=node
return self end
---@alias LinkedListFilter table|any|fun(value: any): boolean
---@class LinkedList<T> : Log.BaseFunctions, { prepend: (fun(self: LinkedList<T>, value: T): LinkedList<T>), append: (fun(self: LinkedList<T>, value: T): LinkedList<T>), push: (fun(self: LinkedList<T>, value: T): LinkedList<T>), pop: (fun(self: LinkedList<T>): T), is_empty: (fun(): boolean), first: (fun(self: LinkedList<T>, filter: LinkedListFilter): T|nil), filter: (fun(self: LinkedList<T>, filter: LinkedListFilter): T[]), to_table: (fun(self: LinkedList<T>): T[]), filter_remove: (fun(self: LinkedList<T>, filter: LinkedListFilter): LinkedList<T>), enqueue: (fun(self: LinkedList<T>, value: T): LinkedList<T>), dequeue: (fun(self: LinkedList<T>): T), iterator: (fun(self: LinkedList<T>): fun(): (integer|nil, T|nil)) }
---@operator call:LinkedList
---@field protected head LinkedList.Node|nil
---@field protected tail LinkedList.Node|nil
local LinkedList=class"LinkedList"
function LinkedList:init() self.head=nil
self.tail=nil end

---@param value any
---@return self self for convienience
function LinkedList:prepend(value) local node=LinkedListNode(value):set_next(self.head)
if self.head then self.head:set_prev(node) end
self.head=node
if  not self.tail then self.tail=self.head end
return self end

---@param value any
---@return self self for convienience
function LinkedList:append(value) local node=LinkedListNode(value):set_prev(self.tail)
if self.tail then self.tail:set_next(node) end
self.tail=node
if  not self.head then self.head=self.tail end
return self end

---@param value any
---@return self self for convienience
function LinkedList:push(value) return self:prepend(value) end

---@return any
function LinkedList:pop() local first=self.head
if  not first then return nil end
self.head=first.next
if self.head then self.head:set_prev(nil) end
return first.value end

---@param filter LinkedListFilter
---@return self self for convienience
function LinkedList:filter_remove(filter) local node=self.head
if  not node then return self end
while  not self._filter_node(node,filter) do node=node.next
if  not node then return self end end

local prev=node.prev
if self.tail == node then self.tail=prev end
local next=node.next
if self.head == node then self.head=next end
if prev then prev:set_next(next) end
if next then next:set_prev(prev) end
return self end

---@param value any
---@return self self for convienience
function LinkedList:enqueue(value) return self:append(value) end

---@return any
function LinkedList:dequeue() return self:pop() end
function LinkedList:is_empty() return self.head == nil end
---@param node LinkedList.Node
---@param filter LinkedListFilter the filter. If a table is passed, all keys found in the filter are tested. If a function is passed, the value is tested against that function
---@return boolean passes if the node passes the filter
function LinkedList._filter_node(node,filter) if node == nil or filter == nil then return true end
local value=node.value
if type(filter) == "function" then return filter(value) elseif type(filter) == "table" then if type(value) ~= "table" then return false end

for k,v in pairs(filter) do if value[k] ~= v then return false end end
return true else return value == filter end end

---@param filter LinkedListFilter
---@return any
function LinkedList:first(filter) local node=self.head
if  not node then return nil end
while  not self._filter_node(node,filter) do node=node.next
if  not node then return nil end end
return node.value end

---@param filter LinkedListFilter
---@return any[]
function LinkedList:filter(filter) local list={}
local node=self.head
while node do if self._filter_node(node,filter) then table.insert(list,node.value) end
node=node.next end
return list end
function LinkedList:__pairs() return self:iterator() end
function LinkedList:iterator() local i=0
local node=self.head
return function () if  not node then return nil,nil end
local value=node.value
node=node.next
i=i + 1
return i,value end end

---@return any[]
function LinkedList:to_table() return self:filter() end
return LinkedList