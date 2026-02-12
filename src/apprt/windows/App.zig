const std = @import("std");
const apprt = @import("../../apprt.zig");
const Config = @import("../../config.zig").Config;
const CoreApp = @import("../../App.zig");
const windows = std.os.windows;
const win32 = @import("../../os/windows.zig");

const App = @This();
const log = std.log.scoped(.app);

pub const Options = struct {};

core_app: *CoreApp,
config: Config,

pub fn init(
    self: *App,
    core_app: *CoreApp,
    config: *const Config,
    opts: Options,
) !void {
    _ = opts;

    // Clone config
    var config_clone = try config.clone(core_app.alloc);
    errdefer config_clone.deinit();

    self.* = .{
        .core_app = core_app,
        .config = config_clone,
    };
}

pub fn terminate(self: *App) void {
    self.config.deinit();
}

pub fn run(self: *App) !void {
    var msg: win32.MSG = undefined;
    while (win32.user32.GetMessageW(&msg, null, 0, 0) != 0) {
        _ = win32.user32.TranslateMessage(&msg);
        _ = win32.user32.DispatchMessageW(&msg);

        // Tick the app
        try self.core_app.tick(self);
    }
}

pub fn wakeup(self: *App) void {
    // Post a dummy message to wake up the message loop
    _ = win32.user32.PostThreadMessageW(
        win32.kernel32.GetCurrentThreadId(),
        win32.WM_NULL,
        0,
        0,
    );
}

pub fn wait(self: *App) !void {
    _ = self;
}

pub fn hasGlobalKeybinds(self: *const App) bool {
    _ = self;
    return false;
}

pub fn performAction(
    self: *App,
    target: apprt.Target,
    comptime action: apprt.Action.Key,
    value: apprt.Action.Value(action),
) !bool {
    _ = self;
    _ = target;
    _ = value;
    return false;
}

pub fn performIpc(
    alloc: std.mem.Allocator,
    target: apprt.ipc.Target,
    comptime action: apprt.ipc.Action.Key,
    value: apprt.ipc.Action.Value(action),
) !bool {
    _ = alloc;
    _ = target;
    _ = value;
    return false;
}

pub const KeyEvent = struct {
    // TODO: Map windows key events
};
