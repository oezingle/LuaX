---@meta

---@alias Awesome.Tag.Signal "request::select" | "tagged" | "untagged" | "property::urgent" | "property::urgent_count" | "request::screen" | "removal-pending"

---@class Awesome.CTag
---@field name string Tag name. [Link](https://awesomewm.org/doc/api/classes/tag.html#tag.name)
---@field selected boolean True if the tag is selected to be viewed. [Link](https://awesomewm.org/doc/api/classes/tag.html#tag.selected)
---@field activated boolean True if the tag is active and can be used. [Link](https://awesomewm.org/doc/api/classes/tag.html#tag.activated)
---@field index integer The tag index. [Link](https://awesomewm.org/doc/api/classes/tag.html#tag.index)
---@field screen Screen The tag screen. [Link](https://awesomewm.org/doc/api/classes/tag.html#tag.screen)
---@field master_width_factor number The tag master width factor. 0.0 - 1.0. [Link](https://awesomewm.org/doc/api/classes/tag.master_width_factor)
---@field layout Awesome.Layout The tag client layout. [Link](https://awesomewm.org/doc/api/classes/tag.layout)
---@field layouts Awesome.Layout[] The (proposed) list of available layouts for this tag. [Link](https://awesomewm.org/doc/api/classes/tag.layouts)
---@field volatile boolean Define if the tag must be deleted when the last client is untagged. [Link](https://awesomewm.org/doc/api/classes/tag.volatile)
---@field gap number The gap (spacing, also called useless_gap) between clients. [Link](https://awesomewm.org/doc/api/classes/tag.gap)
---@field gap_single_client boolean Enable gaps for a single client. [Link](https://awesomewm.org/doc/api/classes/tag.html#tag.gap_single_client)
---@field master_fill_policy "expand" | "master_width_factor" Set size fill policy for the master client(s). [Link](https://awesomewm.org/doc/api/classes/tag.html#tag.master_fill_policy)
---@field master_count integer Set the number of master windows. [Link](https://awesomewm.org/doc/api/classes/tag.html#tag.master_count)
---@field icon string|Awesome.Gears.Surface Set the tag icon. [Link](https://awesomewm.org/doc/api/classes/tag.html#tag.icon)
---@field column_count number Set the number of columns. [Link](https://awesomewm.org/doc/api/classes/tag.html#tag.column_count)
---@field clients Awesome.Util.InstanceGetterOrSetter<self, Awesome.Client[]> Get or set the clients attached to this tag. [Link](https://awesomewm.org/doc/api/classes/tag.html#tag:clients)
---@field swap fun(self: self, t: self) Swap 2 tags. [Link](https://awesomewm.org/doc/api/classes/tag.html#tag:swap)
---@field delete fun(self: self) Delete a tag. [Link](https://awesomewm.org/doc/api/classes/tag.html#tag:delete)
---@field view_only fun(self: self) View only a tag. [Link](https://awesomewm.org/doc/api/classes/tag.html#tag:view_only)

---@alias Awesome.Tag Awesome.CTag | Awesome.InstanceSignalable<Awesome.Tag.Signal>

---@class Awesome.CTagModule
---@field instances fun(): integer Get the number of instances. This includes removed tags

---@alias Awesome.TagModule Awesome.CTagModule | Awesome.ClassSignalable<Awesome.Tag.Signal>
