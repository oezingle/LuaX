---@meta

---@enum Awesome.UnixSignal
local unix_signal = {
    SIGCHLD = 17,
    SIGPOLL = 29,
    SIGHUP = 1,
    SIGSTKFLT = 16,
    SIGALRM = 14,
    SIGSTOP = 19,
    SIGTTOU = 22,
    SIGPROF = 27,
    SIGUSR1 = 10,
    SIGTERM = 15,
    SIGIOT = 6,
    SIGSYS = 31,
    SIGXFSZ = 25,
    SIGXCPU = 24,
    SIGTRAP = 5,
    SIGVTALRM = 26,
    SIGILL = 4,
    SIGQUIT = 3,
    SIGTTIN = 21,
    SIGURG = 23,
    SIGFPE = 8,
    SIGPIPE = 13,
    SIGABRT = 6,
    SIGSEGV = 11,
    SIGPWR = 30,
    SIGIO = 29,
    SIGBUS = 7,
    SIGWINCH = 28,
    SIGCONT = 18,
    SIGINT = 2,
    SIGUSR2 = 12,
    SIGCLD = 17,
    SIGTSTP = 20,
    SIGKILL = 9
}

--- https://awesomewm.org/doc/api/libraries/awesome.html
---@class Awesome.CAwesome
---@field register_xproperty fun(name: string, type: "string"|"number"|"boolean")
---@field quit fun(code: integer?) quit Awesome
---@field exec fun(cmd: string) Execute another application, probably a window manager, to replace awesome.
---@field restart fun() restart Awesome
---@field kill fun(pid: integer, signal: Awesome.UnixSignal? ) kill a process. 0 and negative values have special meaning. See `man kill`.
---@field sync fun() Synchronize with the X11 server.
---@field pixbuf_to_surface fun(pixbuf: table, path: unknown?): Awesome.Gears.Surface Translate a GdkPixbuf to a cairo image surface.
---@field load_image fun(path: string): Awesome.Gears.Surface Load an image from its path and return it as a cairo image
---@field set_preferred_icon_size fun(size: number) Set the preferred size for client icons.
---@field spawn unknown Spawn a program on the default screen
---@field xkb_set_layout_group fun(group: integer)  Switch keyboard layout. Integer from 0-3
---@field xkb_get_layout_group fun(): number Get current layout level
---@field xkb_get_group_names fun(): string Get layout short names. Eg 'pc+us+de:2+inet(evdev)+group(alt_shift_toggle)+ctrl(nocaps)'
---@field version string The version of Awesome
---@field release string The release name of Awesome
---@field conffile string The configuration file which has been loaded.
---@field startup boolean True if we are still in startup, false otherwise, ie this isn't an iteration of the main loop
---@field startup_errors string? if errors are present at startup, the error message
---@field composite_manager_running boolean True if a composite manager is running.
---@field unix_signal { SIGCHLD: 17, SIGPOLL: 29, SIGHUP: 1, SIGSTKFLT: 16, SIGALRM: 14, SIGSTOP: 19, SIGTTOU: 22, SIGPROF: 27, SIGUSR1: 10, SIGTERM: 15, SIGIOT: 6, SIGSYS: 31, SIGXFSZ: 25, SIGXCPU: 24, SIGTRAP: 5, SIGVTALRM: 26, SIGILL: 4, SIGQUIT: 3, SIGTTIN: 21, SIGURG: 23, SIGFPE: 8, SIGPIPE: 13, SIGABRT: 6, SIGSEGV: 11, SIGPWR: 30, SIGIO: 29, SIGBUS: 7, SIGWINCH: 28, SIGCONT: 18, SIGINT: 2, SIGUSR2: 12, SIGCLD: 17, SIGTSTP: 20, SIGKILL: 9 } the list of signals you can send to awesome.kill
---@field hostname string The hostname of the computer on which we are running.
---@field themes_path string The path where themes were installed to.
---@field icon_path string The path where icons were installed to.

---@alias Awesome Awesome.CAwesome | Awesome.ClassSignalable<"debug::error" | "debug::deprecation" | "debug::index::miss" | "debug::newindex::miss" | "systray::update" | "wallpaper_changed" | "xkb::map_changed" | "xkb::group_changed." | "refresh" | "startup" | "exit" | "screen::change" | "spawn::canceled" | "spawn::change" | "spawn::completed" | "spawn::initiated" | "spawn::timeout">
